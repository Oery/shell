import QtQuick
import Quickshell
import Quickshell.Io

Scope {
    id: root
    
    property bool isConnected: false
    property string status: "Unknown"
    property var peers: []
    property string currentPeer: ""
    property bool measuringLatency: false
    
    // Process to get tailscale status
    Process {
        id: statusProcess
        command: ["tailscale", "status", "--json"]
        running: false
        
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    const data = JSON.parse(this.text);
                    root.isConnected = data.BackendState === "Running";
                    root.status = data.BackendState;
                    root.peers = Object.keys(data.Peer || {}).map(key => {
                        const peer = data.Peer[key];
                        return {
                            id: key,
                            name: peer.HostName || key,
                            dnsName: peer.DNSName || "",
                            online: peer.Online || false,
                            latency: null,
                            measuringLatency: false,
                            // Use DNS name first, then hostname, then IP from TailscaleIPs
                            pingTarget: peer.DNSName ? peer.DNSName.replace(/\.$/, '') : 
                                       (peer.HostName || peer.TailscaleIPs?.[0] || key)
                        };
                    });
                } catch (e) {
                    root.isConnected = false;
                    root.status = "Error";
                    root.peers = [];
                }
            }
        }
        
        onExited: function(exitCode) {
            if (exitCode !== 0) {
                root.isConnected = false;
                root.status = "Disconnected";
                root.peers = [];
            }
        }
    }
    
    // Process to toggle tailscale
    Process {
        id: toggleProcess
        command: ["tailscale", "up"]
        running: false
        
        onExited: {
            // Refresh status after toggle
            refresh();
        }
    }
    
    // Process to disconnect
    Process {
        id: disconnectProcess
        command: ["tailscale", "down"]
        running: false
        
        onExited: {
            // Refresh status after disconnect
            refresh();
        }
    }
    
    // Process to measure latency
    Process {
        id: latencyProcess
        command: ["tailscale", "ping", "--c=1"]
        running: false
        
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    const peerId = latencyProcess.peerId;
                    const peerIndex = root.peers.findIndex(p => p.id === peerId);
                    if (peerIndex === -1) return;
                    
                    // Parse latency from tailscale ping output
                    const output = this.text;
                    console.log("Tailscale ping output:", output);
                    
                    // Look for latency patterns
                    const latencyMatch = output.match(/time=([0-9.]+)\s*ms/);
                    if (latencyMatch && latencyMatch[1]) {
                        root.peers[peerIndex].latency = parseFloat(latencyMatch[1]);
                        root.peers[peerIndex].measuringLatency = false;
                        console.log("Successfully parsed latency:", parseFloat(latencyMatch[1]));
                    } else if (output.includes("is local Tailscale IP")) {
                        // Local IP, set very low latency
                        root.peers[peerIndex].latency = 0.1;
                        root.peers[peerIndex].measuringLatency = false;
                        console.log("Set local IP latency");
                    } else if (output.includes("pong from") && output.includes("in ")) {
                        // Alternative format: "pong from eden (100.115.204.55) via 149.202.45.32:41641 in 24ms"
                        const altLatencyMatch = output.match(/in\s+([0-9.]+)\s*ms/);
                        if (altLatencyMatch && altLatencyMatch[1]) {
                            root.peers[peerIndex].latency = parseFloat(altLatencyMatch[1]);
                            root.peers[peerIndex].measuringLatency = false;
                            console.log("Successfully parsed latency (alt format):", parseFloat(altLatencyMatch[1]));
                        } else {
                            root.peers[peerIndex].measuringLatency = false;
                            root.peers[peerIndex].latency = null;
                            console.log("Could not parse latency from pong output");
                        }
                    } else {
                        // Could not parse latency
                        root.peers[peerIndex].measuringLatency = false;
                        root.peers[peerIndex].latency = null;
                        console.log("Could not parse latency, unknown format");
                    }
                    
                    // Reset global measuring flag when this is the last peer
                    if (latencyMeasureIndex >= onlinePeersToMeasure.length - 1) {
                        root.measuringLatency = false;
                        console.log("All measurements completed, resetting global flag");
                    }
                } catch (e) {
                    console.log("Error parsing ping output:", e);
                    // Reset measuring state on error
                    const peerId = latencyProcess.peerId;
                    const peerIndex = root.peers.findIndex(p => p.id === peerId);
                    if (peerIndex !== -1) {
                        root.peers[peerIndex].measuringLatency = false;
                    }
                }
            }
        }
        
        onExited: function(exitCode) {
            if (exitCode !== 0) {
                // Reset measuring state on failure
                const peerId = latencyProcess.peerId;
                const peerIndex = root.peers.findIndex(p => p.id === peerId);
                if (peerIndex !== -1) {
                    root.peers[peerIndex].measuringLatency = false;
                    root.peers[peerIndex].latency = null;
                }
            }
        }
        
        property string peerId: ""
    }
    
    // Timer to refresh status periodically
    Timer {
        interval: 5000 // 5 seconds
        running: true
        repeat: true
        onTriggered: root.refresh()
    }
    
    // Function to refresh status
    function refresh() {
        statusProcess.running = true;
    }
    
    // Function to connect
    function connect() {
        toggleProcess.running = true;
    }
    
    // Function to disconnect
    function disconnect() {
        disconnectProcess.running = true;
    }
    
    // Function to get peer info
    function getPeerInfo(peerId) {
        return peers.find(peer => peer.id === peerId);
    }
    
    // Function to measure latency for a specific peer
    function measureLatency(peerId) {
        console.log("measureLatency called for peer:", peerId);
        const peerIndex = root.peers.findIndex(p => p.id === peerId);
        console.log("peerIndex:", peerIndex, "peer exists:", peerIndex !== -1);
        if (peerIndex !== -1) {
            const peer = root.peers[peerIndex];
            console.log("peer online:", peer.online);
            console.log("ping target:", peer.pingTarget);
            console.log("measuringLatency:", root.measuringLatency);
        }
        
        if (peerIndex !== -1 && root.peers[peerIndex].online) {
            root.peers[peerIndex].measuringLatency = true;
            const pingTarget = root.peers[peerIndex].pingTarget;
            latencyProcess.command = ["tailscale", "ping", "--c=1", pingTarget];
            latencyProcess.peerId = peerId;
            console.log("Starting ping process for target:", pingTarget);
            latencyProcess.running = true;
        } else {
            console.log("Not measuring - peer offline or not found");
        }
    }
    
    // Timer for sequential latency measurements
    Timer {
        id: latencyTimer
        interval: 1000 // 1 second between pings
        onTriggered: measureNextPeer()
    }
    
    property int latencyMeasureIndex: 0
    property var onlinePeersToMeasure: []
    
    function measureNextPeer() {
        console.log("measureNextPeer called, index:", latencyMeasureIndex, "total:", onlinePeersToMeasure.length);
        if (latencyMeasureIndex >= onlinePeersToMeasure.length) {
            console.log("All peers measured, resetting");
            root.measuringLatency = false;
            latencyMeasureIndex = 0;
            onlinePeersToMeasure = [];
            return;
        }
        
        const peer = onlinePeersToMeasure[latencyMeasureIndex];
        console.log("Measuring latency for peer:", peer.id, peer.name, "target:", peer.pingTarget);
        measureLatency(peer.id);
        latencyMeasureIndex++;
        
        if (latencyMeasureIndex < onlinePeersToMeasure.length) {
            console.log("Scheduling next peer measurement");
            latencyTimer.restart();
        }
    }
    
    function measureAllLatency() {
        console.log("measureAllLatency called");
        console.log("measuringLatency:", root.measuringLatency);
        console.log("peers count:", root.peers.length);
        console.log("online peers:", root.peers.filter(p => p.online).length);
        
        if (!root.measuringLatency) {
            root.measuringLatency = true;
            onlinePeersToMeasure = root.peers.filter(p => p.online);
            latencyMeasureIndex = 0;
            console.log("Starting measurement for", onlinePeersToMeasure.length, "peers");
            measureNextPeer();
        } else {
            console.log("Already measuring latency");
        }
    }
    
    // Initial refresh
    Component.onCompleted: refresh()
}