pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

Singleton {
    id: leftpanel

    property bool isVisible: false

    function toggle() {
        isVisible = !isVisible;
    }

    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: sidePanel
            required property var modelData

            screen: modelData
            visible: leftpanel.isVisible

            anchors {
                top: true
                left: true
                bottom: true
            }

            implicitWidth: 400
            color: 'transparent'

            exclusiveZone: 0
            focusable: true

            Rectangle {
                color: '#CC080808'
                anchors.fill: parent
                anchors.margins: 5
                radius: 4

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
                    anchors.margins: 10
                    spacing: 10

                    RowLayout {
                        Layout.fillWidth: true

                        StyledText {
                            text: "Tailnet"
                            font.pixelSize: 14
                            font.bold: true
                        }

                        Item {
                            Layout.fillWidth: true
                        }

                        StyledText {
                            text: Tailscale && Tailscale.isConnected ? "Connected" : "Disconnected"
                            font.pixelSize: 10
                            color: Tailscale && Tailscale.isConnected ? '#4CAF50' : '#F44336'
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        implicitHeight: 1
                        color: '#40FFFFFF'
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        spacing: 8

                        ScrollView {
                            Layout.fillWidth: true
                            Layout.fillHeight: true

                            ColumnLayout {
                                width: parent.width
                                spacing: 4

                                Repeater {
                                    model: Tailscale ? Tailscale.peers : []

                                    delegate: Rectangle {
                                        Layout.fillWidth: true
                                        // height: 60
                                        implicitHeight: content.implicitHeight + 16
                                        color: "transparent"
                                        radius: 4
                                        border.color: modelData && modelData.online === true ? '#4CAF50' : '#808080'
                                        border.width: 1

                                        RowLayout {
                                            id: content
                                            anchors.fill: parent
                                            anchors.margins: 8
                                            // spacing: 8

                                            ColumnLayout {
                                                Layout.alignment: Qt.AlignTop
                                                spacing: 2

                                                StyledText {
                                                    text: modelData.name || modelData.id
                                                    font.pixelSize: 11
                                                    font.bold: true
                                                    Layout.fillWidth: true
                                                    elide: Text.ElideRight
                                                }

                                                StyledText {
                                                    text: modelData.dnsName || modelData.id
                                                    font.pixelSize: 9
                                                    color: '#AAAAAA'
                                                    Layout.fillWidth: true
                                                    elide: Text.ElideRight
                                                }

                                                StyledText {
                                                    text: modelData.os
                                                    font.pixelSize: 9
                                                    Layout.fillWidth: true
                                                    elide: Text.ElideRight
                                                }
                                            }

                                            ColumnLayout {
                                                spacing: 2

                                                StyledText {
                                                    Layout.alignment: Qt.AlignRight
                                                    text: modelData.online === true ? "Online" : "Offline"
                                                    font.pixelSize: 9
                                                    color: modelData && modelData.online === true ? '#4CAF50' : '#808080'
                                                }

                                                StyledText {
                                                    Layout.alignment: Qt.AlignRight
                                                    text: modelData.measuringLatency ? "Ping..." : (modelData.latency ? (modelData.latency.toFixed(1) + "ms") : "---")
                                                    font.pixelSize: 9
                                                    color: modelData.latency ? (modelData.latency < 50 ? '#4CAF50' : (modelData.latency < 100 ? '#FFC107' : '#F44336')) : '#AAAAAA'
                                                }

                                                StyledText {

                                                    readonly property var cpus: new Map([["redmi", "Helio G90T"], ["elysium", "Apple M2"], ["stronghold", "Ryzen 9 5900x"], ["l16", "Ryzen 5 Pro 7535U"]])

                                                    function getValue(key) {
                                                        return cpus.get(key);
                                                    }
                                                    Layout.alignment: Qt.AlignRight
                                                    text: getValue(modelData.name) ?? "???"
                                                    color: '#AAAAAA'
                                                    font.pixelSize: 9
                                                }
                                            }
                                        }

                                        MouseArea {
                                            anchors.fill: parent
                                            hoverEnabled: true

                                            onEntered: parent.color = '#20FFFFFF'
                                            onExited: parent.color = "transparent"
                                        }
                                    }
                                }
                            }
                        }

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 8

                            Rectangle {
                                Layout.preferredWidth: 70
                                height: 30
                                color: '#2196F3'
                                radius: 4

                                Text {
                                    anchors.centerIn: parent
                                    text: "Refresh"
                                    color: 'white'
                                    font.family: "JetBrains Mono"
                                    font.pixelSize: 11
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    hoverEnabled: true

                                    onEntered: parent.color = '#1976D2'
                                    onExited: parent.color = '#2196F3'
                                    onPressed: parent.color = '#0D47A1'
                                    onReleased: {
                                        if (containsMouse) {
                                            parent.color = '#2196F3';
                                        }
                                    }
                                    onClicked: if (Tailscale)
                                        Tailscale.refresh()
                                }
                            }

                            Rectangle {
                                Layout.preferredWidth: 70
                                height: 30
                                color: (Tailscale && Tailscale.measuringLatency) ? '#CCCCCC' : '#FF9800'
                                radius: 4

                                Text {
                                    anchors.centerIn: parent
                                    text: (Tailscale && Tailscale.measuringLatency) ? "Pinging..." : "Ping All"
                                    color: (Tailscale && Tailscale.measuringLatency) ? '#666666' : 'white'
                                    font.family: "JetBrains Mono"
                                    font.pixelSize: 11
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    hoverEnabled: true && !(Tailscale && Tailscale.measuringLatency)

                                    onEntered: if (!Tailscale || !Tailscale.measuringLatency)
                                        parent.color = '#F57C00'
                                    onExited: if (!Tailscale || !Tailscale.measuringLatency)
                                        parent.color = '#FF9800'
                                    onPressed: if (!Tailscale || !Tailscale.measuringLatency)
                                        parent.color = '#E65100'
                                    onReleased: {
                                        if (containsMouse && (!Tailscale || !Tailscale.measuringLatency)) {
                                            parent.color = '#FF9800';
                                        }
                                    }
                                    onClicked: {
                                        if (Tailscale && !Tailscale.measuringLatency) {
                                            console.log("Ping All button clicked");
                                            console.log("Tailscale:", Tailscale);
                                            console.log("measuringLatency:", Tailscale.measuringLatency);
                                            console.log("Calling measureAllLatency");
                                            Tailscale.measureAllLatency();
                                        } else {
                                            console.log("Not calling measureAllLatency - measuring in progress or Tailscale not available");
                                        }
                                    }
                                }
                            }
                        }
                    }

                    Item {
                        Layout.fillHeight: true
                    }
                }
            }
        }
    }
}
