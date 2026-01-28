import QtQuick
import QtQuick.Layouts
import Quickshell

Scope {
    id: root

    // property alias sidePanelVisible: leftpanel.isVisible

    // SidePanel {
    //     id: leftpanel
    //     tailscale: tailscale
    // }

    Variants {
        model: Quickshell.screens

        PanelWindow {
            required property var modelData

            screen: modelData
            implicitHeight: 28
            color: 'transparent'

            anchors {
                top: true
                left: true
                right: true
            }

            Rectangle {
                // color: '#d8080808'
                // color: '#f2080808'
                color: '#CC080808'

                anchors.fill: parent

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 5
                    anchors.rightMargin: 5

                    // OS Logo
                    // StyledText { text: '󰣇 |' }
                    // StyledText { text: '₍^. .^₎⟆ | ' }
                    // StyledText { text: 'λ |' }
                    // text: "󰜂"
                    // 󱄅
                    RowLayout {
                        spacing: 0

                        Rectangle {
                            // implicitHeight: content.implicitHeight
                            // implicitWidth: content.implicitWidth
                            width: 24
                            height: 20
                            color: "transparent"
                            radius: 4

                            StyledText {
                                id: content
                                anchors.centerIn: parent
                                text: '󱄅'
                                font.pixelSize: 14
                                color: '#F7F1FF'
                            }

                            MouseArea {
                                anchors.fill: parent
                                hoverEnabled: true

                                onEntered: parent.color = '#20FFFFFF'
                                onExited: parent.color = "transparent"
                                onPressed: parent.color = '#40FFFFFF'
                                onReleased: parent.color = containsMouse ? '#20FFFFFF' : "transparent"
                                onClicked: SidePanel.toggle()
                            }
                        }

                        StyledText {
                            text: '| '
                        }

                        Workspaces {}

                        WindowTitle {}
                    }

                    Item {
                        Layout.fillWidth: true
                    }

                    RowLayout {
                        spacing: 0

                        Battery {}

                        StyledText {
                            text: Time.time
                        }

                        SystemTray {}
                    }
                }
            }
        }
    }
}
