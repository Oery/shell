pragma Singleton

import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland
import QtQuick
import QtQuick.Layouts
import qs.utils
import qs.services

Singleton {
    id: leftpanel

    property bool isVisible: false

    // Monitor this panel opened on, captured at open time so it doesn't jump
    // if focus moves elsewhere while it's up.
    property string activeScreen: ""

    function toggle() {
        if (!isVisible)
            activeScreen = FocusedScreen.name;
        isVisible = !isVisible;
    }

    // Personal hardware labels, keyed by device name.
    readonly property var cpus: ({
            "redmi": "Helio G90T",
            "elysium": "Apple M2",
            "stronghold": "Ryzen 9 5900X",
            "l16": "Ryzen 5 Pro 7535U"
        })

    function cpuName(name) {
        return cpus[name] || "";
    }

    function osIcon(os) {
        const o = (os || "").toLowerCase();
        if (o === "linux")
            return "󰌽";
        if (o === "android")
            return "󰀲";
        if (o === "macos" || o === "darwin" || o === "ios")
            return "󰀵";
        if (o === "windows")
            return "󰖳";
        return "󰟀";
    }

    function latencyColor(ms) {
        if (ms === null || ms === undefined)
            return '#8A8497';
        if (ms < 50)
            return '#4CAF50';
        if (ms < 100)
            return '#FFC107';
        return '#F44336';
    }

    function relTime(iso) {
        if (!iso || iso.indexOf("0001") === 0)
            return "";
        const t = Date.parse(iso);
        if (isNaN(t))
            return "";
        let s = Math.floor((Date.now() - t) / 1000);
        if (s < 60)
            return "just now";
        if (s < 3600)
            return Math.floor(s / 60) + "m ago";
        if (s < 86400)
            return Math.floor(s / 3600) + "h ago";
        return Math.floor(s / 86400) + "d ago";
    }

    function connLabel(peer) {
        if (peer.self)
            return "this device";
        if (!peer.online) {
            const seen = relTime(peer.lastSeen);
            return seen ? "seen " + seen : "offline";
        }
        if (peer.curAddr && peer.curAddr.length > 0)
            return "direct";
        if (peer.relay && peer.relay.length > 0)
            return "relay · " + peer.relay;
        return "relay";
    }

    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: sidePanel
            required property var modelData

            WlrLayershell.namespace: "quickshell-panel"

            screen: modelData
            // Only the focused monitor's instance shows. Otherwise every
            // monitor gets a copy, and their focus grabs cancel each other out.
            visible: leftpanel.isVisible && FocusedScreen.matches(modelData, leftpanel.activeScreen)

            anchors {
                top: true
                left: true
                bottom: true
            }

            implicitWidth: 400
            color: 'transparent'

            exclusiveZone: 0
            focusable: true

            HyprlandFocusGrab {
                windows: [sidePanel]
                active: sidePanel.visible
                onCleared: leftpanel.isVisible = false
            }

            Rectangle {
                color: Theme.panelBackground
                anchors.fill: parent
                anchors.margins: 5
                radius: 10

                focus: true
                Keys.enabled: true
                Keys.onPressed: event => {
                    if (event.key === Qt.Key_Escape) {
                        leftpanel.isVisible = false;
                        event.accepted = true;
                    }
                }

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 16
                    spacing: 14

                    // Header
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 11

                        StyledText {
                            text: "󰛳"
                            font.pixelSize: 19
                            color: Tailscale.isConnected ? '#4CAF50' : '#8A8497'
                        }

                        ColumnLayout {
                            spacing: 0

                            StyledText {
                                text: "Tailnet"
                                font.pixelSize: 14
                                font.bold: true
                            }

                            StyledText {
                                text: (Tailscale.selfName ? Tailscale.selfName + " · " : "") + Tailscale.onlineCount + "/" + Tailscale.totalCount + " online"
                                font.pixelSize: 9
                                color: '#8A8497'
                            }
                        }

                        Item {
                            Layout.fillWidth: true
                        }

                        Rectangle {
                            implicitWidth: statusRow.implicitWidth + 16
                            implicitHeight: 22
                            radius: 11
                            color: Tailscale.isConnected ? '#1F4CAF50' : '#1FF44336'

                            RowLayout {
                                id: statusRow
                                anchors.centerIn: parent
                                spacing: 5

                                Rectangle {
                                    width: 7
                                    height: 7
                                    radius: 4
                                    color: Tailscale.isConnected ? '#4CAF50' : '#F44336'
                                }

                                StyledText {
                                    text: Tailscale.isConnected ? "Connected" : "Disconnected"
                                    font.pixelSize: 10
                                    color: Tailscale.isConnected ? '#8BE68F' : '#F5A3A0'
                                }
                            }
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        implicitHeight: 1
                        color: '#20FFFFFF'
                    }

                    // Peer list
                    ListView {
                        id: peerList
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        clip: true
                        spacing: 8
                        model: Tailscale.peers
                        boundsBehavior: Flickable.StopAtBounds
                        visible: Tailscale.totalCount > 0

                        delegate: Rectangle {
                            id: card
                            required property var modelData

                            width: ListView.view.width
                            implicitHeight: cardRow.implicitHeight + 20
                            radius: 12
                            opacity: modelData.online ? 1 : 0.5
                            color: cardMouse.containsMouse && modelData.online && !modelData.self ? '#1CFFFFFF' : '#12FFFFFF'

                            Behavior on color {
                                ColorAnimation {
                                    duration: 120
                                }
                            }

                            // Status accent stripe
                            Rectangle {
                                anchors.left: parent.left
                                anchors.top: parent.top
                                anchors.bottom: parent.bottom
                                anchors.margins: 8
                                width: 3
                                radius: 2
                                color: card.modelData.self ? '#2196F3' : (card.modelData.online ? '#4CAF50' : '#6A6475')
                            }

                            MouseArea {
                                id: cardMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: card.modelData.online && !card.modelData.self ? Qt.PointingHandCursor : Qt.ArrowCursor
                                onClicked: if (card.modelData.online && !card.modelData.self)
                                    Tailscale.pingPeer(card.modelData.id)
                            }

                            RowLayout {
                                id: cardRow
                                anchors.left: parent.left
                                anchors.right: parent.right
                                anchors.verticalCenter: parent.verticalCenter
                                anchors.leftMargin: 16
                                anchors.rightMargin: 12
                                spacing: 11

                                // OS tile with online dot
                                Rectangle {
                                    Layout.preferredWidth: 38
                                    Layout.preferredHeight: 38
                                    radius: 10
                                    color: '#16FFFFFF'

                                    StyledText {
                                        anchors.centerIn: parent
                                        text: leftpanel.osIcon(card.modelData.os)
                                        font.pixelSize: 18
                                        color: card.modelData.online ? '#F7F1FF' : '#8A8497'
                                    }

                                    Rectangle {
                                        width: 11
                                        height: 11
                                        radius: 6
                                        color: card.modelData.online ? '#4CAF50' : '#6A6475'
                                        border.color: '#0A0A0A'
                                        border.width: 2
                                        anchors.right: parent.right
                                        anchors.bottom: parent.bottom
                                        anchors.rightMargin: -2
                                        anchors.bottomMargin: -2
                                    }
                                }

                                ColumnLayout {
                                    Layout.fillWidth: true
                                    spacing: 3

                                    RowLayout {
                                        Layout.fillWidth: true
                                        spacing: 6

                                        StyledText {
                                            text: card.modelData.name
                                            font.pixelSize: 12
                                            font.bold: true
                                            color: '#F7F1FF'
                                            elide: Text.ElideRight
                                            Layout.fillWidth: true
                                        }

                                        Rectangle {
                                            visible: card.modelData.self
                                            implicitWidth: youLabel.implicitWidth + 10
                                            implicitHeight: 15
                                            radius: 4
                                            color: '#332196F3'

                                            StyledText {
                                                id: youLabel
                                                anchors.centerIn: parent
                                                text: "you"
                                                font.pixelSize: 8
                                                color: '#7EC0FF'
                                            }
                                        }

                                        Rectangle {
                                            visible: card.modelData.exitNode
                                            implicitWidth: exitLabel.implicitWidth + 10
                                            implicitHeight: 15
                                            radius: 4
                                            color: '#334CAF50'

                                            StyledText {
                                                id: exitLabel
                                                anchors.centerIn: parent
                                                text: "exit"
                                                font.pixelSize: 8
                                                color: '#8BE68F'
                                            }
                                        }

                                        StyledText {
                                            visible: !card.modelData.self
                                            text: {
                                                if (card.modelData.measuringLatency)
                                                    return "ping…";
                                                if (card.modelData.latency !== null && card.modelData.latency !== undefined)
                                                    return card.modelData.latency === 0 ? "0ms" : card.modelData.latency.toFixed(1) + "ms";
                                                return card.modelData.online ? "ping" : "";
                                            }
                                            font.pixelSize: 10
                                            color: card.modelData.measuringLatency ? '#8A8497' : leftpanel.latencyColor(card.modelData.latency)
                                            opacity: (card.modelData.latency === null && !card.modelData.measuringLatency) ? 0.55 : 1
                                        }
                                    }

                                    RowLayout {
                                        Layout.fillWidth: true
                                        spacing: 6

                                        StyledText {
                                            text: card.modelData.ipv4
                                            font.pixelSize: 9
                                            color: '#8A8497'
                                        }

                                        StyledText {
                                            text: "󰆏"
                                            font.pixelSize: 10
                                            color: copyMouse.containsMouse ? '#F7F1FF' : '#6A6475'
                                            visible: card.modelData.ipv4.length > 0

                                            MouseArea {
                                                id: copyMouse
                                                anchors.fill: parent
                                                anchors.margins: -5
                                                hoverEnabled: true
                                                cursorShape: Qt.PointingHandCursor
                                                onClicked: Tailscale.copyText(card.modelData.ipv4)
                                            }
                                        }

                                        StyledText {
                                            text: "·"
                                            font.pixelSize: 9
                                            color: '#4A4652'
                                        }

                                        StyledText {
                                            text: leftpanel.connLabel(card.modelData)
                                            font.pixelSize: 9
                                            color: '#8A8497'
                                            elide: Text.ElideRight
                                        }

                                        Item {
                                            Layout.fillWidth: true
                                        }

                                        StyledText {
                                            text: leftpanel.cpuName(card.modelData.name)
                                            font.pixelSize: 9
                                            color: '#6A6475'
                                            visible: text.length > 0
                                        }
                                    }
                                }
                            }
                        }
                    }

                    // Empty state
                    Item {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        visible: Tailscale.totalCount === 0

                        ColumnLayout {
                            anchors.centerIn: parent
                            spacing: 6

                            StyledText {
                                Layout.alignment: Qt.AlignHCenter
                                text: "󰦞"
                                font.pixelSize: 26
                                color: '#3A3A44'
                            }

                            StyledText {
                                Layout.alignment: Qt.AlignHCenter
                                text: Tailscale.isConnected ? "No peers" : "Tailscale not connected"
                                font.pixelSize: 11
                                color: '#6A6475'
                            }
                        }
                    }

                    // Footer actions
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 8

                        Rectangle {
                            Layout.fillWidth: true
                            implicitHeight: 34
                            radius: 10
                            color: refreshMouse.containsMouse ? '#24FFFFFF' : '#14FFFFFF'

                            Behavior on color {
                                ColorAnimation {
                                    duration: 120
                                }
                            }

                            RowLayout {
                                anchors.centerIn: parent
                                spacing: 6

                                StyledText {
                                    text: "󰑐"
                                    font.pixelSize: 13
                                    color: '#CFC9D9'
                                }

                                StyledText {
                                    text: "Refresh"
                                    font.pixelSize: 11
                                    color: '#CFC9D9'
                                }
                            }

                            MouseArea {
                                id: refreshMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: Tailscale.refresh()
                            }
                        }

                        Rectangle {
                            id: pingBtn
                            Layout.fillWidth: true
                            implicitHeight: 34
                            radius: 10

                            readonly property bool busy: Tailscale.measuringLatency

                            color: pingBtn.busy ? '#1F2196F3' : (pingMouse.containsMouse ? '#3D2196F3' : '#262196F3')

                            Behavior on color {
                                ColorAnimation {
                                    duration: 120
                                }
                            }

                            RowLayout {
                                anchors.centerIn: parent
                                spacing: 6

                                StyledText {
                                    text: "󰓅"
                                    font.pixelSize: 13
                                    color: '#7EC0FF'
                                }

                                StyledText {
                                    text: pingBtn.busy ? "Pinging…" : "Ping all"
                                    font.pixelSize: 11
                                    color: '#7EC0FF'
                                }
                            }

                            MouseArea {
                                id: pingMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: pingBtn.busy ? Qt.ArrowCursor : Qt.PointingHandCursor
                                onClicked: Tailscale.measureAllLatency()
                            }
                        }
                    }
                }
            }
        }
    }
}
