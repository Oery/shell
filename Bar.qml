import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland

Scope {
    id: root
    
    property alias sidePanelVisible: sidePanel.isVisible

    SidePanel {
        id: sidePanel
        tailscale: tailscale
    }

    Tailscale {
    id: tailscale
}

    Variants {
        model: Quickshell.screens

        PanelWindow {
            required property var modelData

            screen: modelData
            implicitHeight: 28
            // color: '#E5121517'
            color: 'transparent'

            anchors {
                top: true
                left: true
                right: true
            }

            Rectangle {
                // radius: 4

                // color: '#d8080808'
                color: '#f2080808'

                anchors.fill: parent

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 10
                    anchors.rightMargin: 5

                    // OS Logo
                    // StyledText { text: '󰣇 |' }
                    // StyledText { text: '₍^. .^₎⟆ | ' }
                    // StyledText { text: 'λ |' }
                    RowLayout {
                        // spacing: 6

                        Rectangle {
                            width: 24
                            height: 20
                            color: "transparent"
                            radius: 4
                            
                            Text {
                                anchors.centerIn: parent
                                text: sidePanel.isVisible ? '󰅰' : '󰅀'
                                color: '#F7F1FF'
                                font.family: "JetBrains Mono"
                                font.pixelSize: 11
                            }
                            
                            MouseArea {
                                anchors.fill: parent
                                hoverEnabled: true
                                
                                onEntered: parent.color = '#20FFFFFF'
                                onExited: parent.color = "transparent"
                                onPressed: parent.color = '#40FFFFFF'
                                onReleased: parent.color = containsMouse ? '#20FFFFFF' : "transparent"
                                onClicked: sidePanel.toggle()
                            }
                        }

                        StyledText { text: '󰜂 |' }

                        WorkspacesNum {}

                        WindowTitle {}
                    }

                    Item { Layout.fillWidth: true }

                    RowLayout {
                        spacing: 0

                        Battery {}

                        StyledText { text: Time.time }

                        SystemTray {}
                    }
                }
            }
        }
    }
}
