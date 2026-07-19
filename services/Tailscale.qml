pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

import qs.panels

Singleton {
    id: root

    property bool isConnected: false
    property string status: "Unknown"
    property var peers: []
    property bool measuringLatency: false

    readonly property int onlineCount: peers.filter(p => p.online).length
    readonly property int totalCount: peers.length
    readonly property string selfName: {
        const s = peers.find(p => p.self);
        return s ? s.name : "";
    }

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

                    data.Peer = data.Peer || {};
                    data.Peer["!self"] = data.Self;

                    const oldPeers = root.peers || [];
                    let newPeers = Object.keys(data.Peer).map(key => {
                        const peer = data.Peer[key] || {};
                        const oldPeer = oldPeers.find(p => p.id === key);
                        const ips = peer.TailscaleIPs || [];
                        const ipv4 = ips.find(ip => ip.indexOf(".") !== -1) || ips[0] || "";
                        const isSelf = key === "!self";
                        return {
                            id: key,
                            self: isSelf,
                            name: (peer.DNSName ? peer.DNSName.split(".")[0] : "") || peer.HostName || key,
                            hostName: peer.HostName || "",
                            ipv4: ipv4,
                            os: peer.OS || "unknown",
                            online: isSelf ? root.isConnected : (peer.Online || false),
                            exitNode: peer.ExitNode || false,
                            exitNodeOption: peer.ExitNodeOption || false,
                            active: peer.Active || false,
                            curAddr: peer.CurAddr || "",
                            relay: peer.Relay || "",
                            lastSeen: peer.LastSeen || "",
                            rxBytes: peer.RxBytes || 0,
                            txBytes: peer.TxBytes || 0,
                            latency: oldPeer ? oldPeer.latency : null,
                            measuringLatency: oldPeer ? oldPeer.measuringLatency : false,
                            pingTarget: ipv4
                        };
                    });

                    newPeers.sort((a, b) => {
                        if (a.self !== b.self)
                            return a.self ? -1 : 1;
                        if (a.online !== b.online)
                            return a.online ? -1 : 1;
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

    // Sequential per-peer latency probe. One ping runs at a time; when it
    // finishes we advance the queue.
    Process {
        id: pingProcess
        property string peerId: ""
        running: false

        stdout: StdioCollector {
            onStreamFinished: {
                const out = this.text;
                let latency = null;
                if (out.includes("is local Tailscale IP")) {
                    latency = 0;
                } else {
                    const m = out.match(/in\s+([0-9.]+)\s*ms/) || out.match(/time=([0-9.]+)\s*ms/);
                    if (m)
                        latency = parseFloat(m[1]);
                }
                root._patchPeer(pingProcess.peerId, {
                    latency: latency,
                    measuringLatency: false
                });
                root._pingNext();
            }
        }
    }

    property var _pingQueue: []

    function _patchPeer(id, patch) {
        root.peers = root.peers.map(p => p.id === id ? Object.assign({}, p, patch) : p);
    }

    function _pingNext() {
        if (root._pingQueue.length === 0) {
            root.measuringLatency = false;
            return;
        }
        const id = root._pingQueue.shift();
        const peer = root.peers.find(p => p.id === id);
        if (!peer || !peer.pingTarget) {
            root._pingNext();
            return;
        }
        pingProcess.peerId = id;
        pingProcess.command = ["tailscale", "ping", "--c=1", "--timeout=3s", peer.pingTarget];
        pingProcess.running = true;
    }

    function pingPeer(id) {
        if (pingProcess.running)
            return;
        const peer = root.peers.find(p => p.id === id);
        if (!peer || !peer.pingTarget)
            return;
        root._patchPeer(id, {
            measuringLatency: true
        });
        root._pingQueue = [id];
        _pingNext();
    }

    function measureAllLatency() {
        if (root.measuringLatency || pingProcess.running)
            return;
        const ids = root.peers.filter(p => p.online && p.pingTarget).map(p => p.id);
        if (ids.length === 0)
            return;
        root.measuringLatency = true;
        root.peers = root.peers.map(p => ids.indexOf(p.id) !== -1 ? Object.assign({}, p, {
                measuringLatency: true
            }) : p);
        root._pingQueue = ids;
        _pingNext();
    }

    Process {
        id: clipProcess
        running: false
    }

    function copyText(text) {
        if (!text)
            return;
        clipProcess.command = ["wl-copy", String(text)];
        clipProcess.running = true;
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
