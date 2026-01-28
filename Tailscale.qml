pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    property bool isConnected: false
    property string status: "Unknown"
    property var peers: []
    property bool measuringLatency: false

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

                    data.Peer["!self"] = data.Self;

                    const oldPeers = root.peers || [];
                    let newPeers = Object.keys(data.Peer || {}).map(key => {
                        const peer = data.Peer[key];
                        const oldPeer = oldPeers.find(p => p.id === key);
                        return {
                            id: key,
                            name: peer.DNSName.split(".")[0] || key,
                            dnsName: peer.TailscaleIPs[0] || "",
                            os: peer.OS || "Unknown",
                            online: peer.Online || false,
                            latency: oldPeer ? oldPeer.latency : null,
                            measuringLatency: false,
                            pingTarget: peer.DNSName ? peer.DNSName.replace(/\.$/, '') : (peer.HostName || peer.TailscaleIPs?.[0] || key)
                        };
                    });

                    newPeers.sort((a, b) => {
                        if (a.online !== b.online) {
                            return a.online ? -1 : 1;
                        }
                        return a.name.localeCompare(b.name, undefined, {
                            sensitivity: 'base'
                        });
                    });

                    root.peers = newPeers;
                } catch (e) {
                    root.isConnected = false;
                    root.status = "Error";
                    root.peers = [];
                }
            }
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
                    if (peerIndex === -1) {
                        console.log("Peer not found for ID:", peerId);
                        return;
                    }

                    console.log("Ping output for peer", peerId, ":", this.text);

                    const output = this.text;

                    if (output.includes("time=") && output.includes("ms")) {
                        const timeMatch = output.match(/time=([0-9.]+)\s*ms/);
                        if (timeMatch && timeMatch[1]) {
                            root.peers[peerIndex].latency = parseFloat(timeMatch[1]);
                            root.peers[peerIndex].measuringLatency = false;
                            console.log("Successfully parsed latency:", parseFloat(timeMatch[1]));
                        }
                    } else if (output.includes("is local Tailscale IP")) {
                        root.peers[peerIndex].latency = 0;
                        root.peers[peerIndex].measuringLatency = false;
                    } else if (output.includes("pong from") && output.includes("in ")) {
                        const timeMatch = output.match(/in\s+([0-9.]+)\s*ms/);
                        if (timeMatch && timeMatch[1]) {
                            root.peers[peerIndex].latency = parseFloat(timeMatch[1]);
                            root.peers[peerIndex].measuringLatency = false;
                            console.log("Successfully parsed latency:", parseFloat(timeMatch[1]));
                        }
                    } else {
                        root.peers[peerIndex].measuringLatency = false;
                        root.peers[peerIndex].latency = null;
                        console.log("Could not parse latency from pong output");
                    }

                    const newPeers = [...root.peers];
                    root.peers = newPeers;
                    root.peersChanged();
                } catch (e) {
                    console.log("Error parsing ping output:", e);
                    const peerId = latencyProcess.peerId;
                    const peerIndex = root.peers.findIndex(p => p.id === peerId);
                    if (peerIndex !== -1) {
                        root.peers[peerIndex].measuringLatency = false;
                    }
                }
            }
        }

        property string peerId: ""
    }

    Timer {
        id: latencyTimer
        running: false
        interval: 500
        onTriggered: measureNextPeer()
    }

    property int latencyMeasureIndex: 0
    property var onlinePeersToMeasure: []

    function measureNextPeer() {
        if (latencyMeasureIndex >= onlinePeersToMeasure.length) {
            root.measuringLatency = false;
            console.log("All measurements completed, resetting global flag");
            return;
        }

        const peer = onlinePeersToMeasure[latencyMeasureIndex];
        console.log("Measuring latency for peer:", peer.id, peer.name, "target:", peer.pingTarget);
        measureLatency(peer.id);
        latencyMeasureIndex++;

        if (latencyMeasureIndex < onlinePeersToMeasure.length) {
            latencyTimer.restart();
        }
    }

    function measureLatency(peerId) {
        root.measuringLatency = true;
        onlinePeersToMeasure = root.peers.filter(p => p.online);
        latencyMeasureIndex = 0;
        measureNextPeer();
    }

    function measureAllLatency() {
        if (!root.measuringLatency) {
            root.measuringLatency = true;
            onlinePeersToMeasure = root.peers.filter(p => p.online);
            latencyMeasureIndex = 0;
            measureNextPeer();
            root.measuringLatency = false;
        }
    }

    Timer {
        id: statusRefreshTimer
        interval: 2000
        running: SidePanel.isVisible
        repeat: true
        triggeredOnStart: true

        onTriggered: root.refresh()
    }

    function refresh() {
        statusProcess.running = true;
    }

    function getPeerInfo(peerId) {
        return root.peers.find(peer => peer.id === peerId);
    }

    Component.onCompleted: refresh()
}
