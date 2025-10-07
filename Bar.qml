import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland

Scope {
    id: root

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

            margins {
                // top: 5
                // left: 5
                // right: 5
            }

            Rectangle {
                // radius: 4

                color: '#d8080808'

                anchors.fill: parent

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 10
                    anchors.rightMargin: 10
                    spacing: 10
                    // spacing: 15

                    // OS Logo
                    // StyledText { text: '󰣇 |' }
                    // StyledText { text: '₍^. .^₎⟆ | ' }
                    // StyledText { text: 'λ |' }
                    StyledText { text: '󰜂 |' }

                    // Workspaces {}
                    WorkspacesNum {}

                    WindowTitle {}

                    Item { Layout.fillWidth: true }

                    SystemTray {}

                    StyledText { text: Time.time }
                }
            }
        }
    }
}
