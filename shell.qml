//@ pragma UseQApplication
//@ pragma IconTheme YAMIS

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Services.Notifications
import Quickshell.Wayland
import qs.panels
import qs.desktop
import qs.utils
import qs.services

Scope {
    // Eagerly instantiate the notification service so its server registers
    // on DBus at startup (not lazily when the panel first opens).
    property var _notifications: Notifications

    Connections {
        target: Notifications
        function onPopup(notif) {
            var item = notificationItem.createObject(notificationColumn);
            item.notif = notif;
        }
    }

    Component {
        id: notificationItem
        Rectangle {
            id: popupRoot
            width: 320
            height: 80
            color: "#E5080808"
            radius: 5
            property var notif: null

            // If the notification is dismissed elsewhere while its popup is
            // still visible, remove the popup too.
            Connections {
                target: popupRoot.notif
                function onClosed(reason) {
                    popupRoot.destroy();
                }
            }

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 12
                spacing: 6
                StyledText {
                    text: (notif && notif.appName) || "Notification"
                    font.pixelSize: 11
                    font.bold: true
                    color: "#AAAAAA"
                    Layout.fillWidth: true
                }
                StyledText {
                    text: notif ? notif.summary : ""
                    font.pixelSize: 13
                    font.bold: true
                    color: "#FFFFFF"
                    Layout.fillWidth: true
                    wrapMode: Text.Wrap
                    maximumLineCount: 2
                }
            }

            // Auto-hide the popup after a few seconds, but keep the
            // notification in history (don't dismiss it).
            Timer {
                running: true
                repeat: false
                interval: 5000
                onTriggered: popupRoot.destroy()
            }
            MouseArea {
                anchors.fill: parent
                onClicked: if (popupRoot.notif)
                    popupRoot.notif.dismiss()
            }
        }
    }

    PanelWindow {
        id: notificationPanel
        visible: true
        color: "transparent"
        exclusiveZone: 0
        focusable: false

        WlrLayershell.layer: WlrLayer.Overlay

        screen: Quickshell.screens.length > 0 ? Quickshell.screens[0] : null
        implicitWidth: 350
        implicitHeight: 1000

        mask: Region {
            item: notificationColumn
        }

        anchors {
            top: true
            right: true
            bottom: true
        }

        Column {
            id: notificationColumn
            anchors.top: parent.top
            anchors.right: parent.right
            anchors.topMargin: 5
            anchors.rightMargin: 5
            width: 320
            spacing: 5
        }
    }

    property var _appLauncher: AppLauncher
    property var _desktopEntries: DesktopEntries

    Bar {}
    Wallpaper {}

    IpcHandler {
        target: "leftpanel"
        function toggle(): void {
            SidePanel.toggle();
        }
    }

    IpcHandler {
        target: "launcher"
        function toggle(): void {
            AppLauncher.toggle();
        }
    }

    IpcHandler {
        target: "rightpanel"
        function toggle(): void {
            RightPanel.toggle();
        }
    }

    IpcHandler {
        target: "notifications"
        function clear(): void {
            Notifications.clearAll();
        }
    }

    IpcHandler {
        target: "tailscale"
        function pingall(): void {
            Tailscale.measureAllLatency();
        }
    }

    IpcHandler {
        target: "wallpaper"
        function toggle(): void {
            Config.wallpaperSelectorVisible = !Config.wallpaperSelectorVisible;
        }
    }
}
