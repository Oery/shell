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
            implicitHeight: 20
            // color: '#E5121517'
            color: '#E5080808'

            anchors {
                top: true
                left: true
                right: true
            }

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 5
                anchors.rightMargin: 5
                spacing: 10

                // OS Logo
                StyledText { text: '󰣇' }

                // Workspaces {}
                WorkspacesNum {}

                Item { Layout.fillWidth: true }

                SystemTray {}

                StyledText { text: Time.time }
            }
        }
    }
}
