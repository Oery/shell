pragma Singleton

import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import Quickshell.Services.Notifications
import QtQuick
import QtQuick.Layouts
import qs.utils
import qs.panels.sliders
import qs.system
import qs.services

Singleton {
    id: rightpanel

    property bool isVisible: false
    property string activeScreen: ""
    property string hostName: "localhost"

    Process {
        command: ["hostname"]
        running: true

        stdout: StdioCollector {
            onStreamFinished: {
                const value = this.text.trim();
                if (value.length > 0)
                    rightpanel.hostName = value;
            }
        }
    }

    function toggle() {
        if (!isVisible)
            activeScreen = FocusedScreen.name;
        isVisible = !isVisible;
    }

    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: rightPanel
            required property var modelData

            screen: modelData
            visible: rightpanel.isVisible && FocusedScreen.matches(modelData, rightpanel.activeScreen)

            anchors {
                top: true
                right: true
                bottom: true
            }

            implicitWidth: 400
            color: "transparent"
            exclusiveZone: 0
            focusable: true

            HyprlandFocusGrab {
                windows: [rightPanel]
                active: rightPanel.visible
                onCleared: rightpanel.isVisible = false
            }

            Rectangle {
                anchors.fill: parent
                anchors.margins: 5
                radius: 10
                color: "#E5080808"

                focus: true
                Keys.enabled: true
                Keys.onPressed: event => {
                    if (event.key === Qt.Key_Escape) {
                        rightpanel.isVisible = false;
                        event.accepted = true;
                    }
                }

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 16
                    spacing: 14

                    // Mirrors the compact identity/status header of the Tailnet panel.
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 11

                        StyledText {
                            text: "󰒓"
                            font.pixelSize: 19
                            color: "#CFC9D9"
                        }

                        ColumnLayout {
                            spacing: 0

                            StyledText {
                                text: rightpanel.hostName
                                font.pixelSize: 14
                                font.bold: true
                            }

                            StyledText {
                                text: Notifications.count === 0 ? "System controls · all clear" : "System controls · " + Notifications.count + (Notifications.count === 1 ? " notification" : " notifications")
                                font.pixelSize: 9
                                color: "#8A8497"
                            }
                        }

                        Item { Layout.fillWidth: true }

                        ColumnLayout {
                            spacing: 0

                            StyledText {
                                Layout.alignment: Qt.AlignRight
                                text: clock.date.toLocaleString(Qt.locale("en_EN"), "HH:mm")
                                font.pixelSize: 13
                                font.bold: true
                                color: "#F7F1FF"
                            }

                            StyledText {
                                Layout.alignment: Qt.AlignRight
                                text: clock.date.toLocaleString(Qt.locale("en_EN"), "ddd dd MMM")
                                font.pixelSize: 9
                                color: "#8A8497"
                            }
                        }

                        SystemClock {
                            id: clock
                            precision: SystemClock.Minutes
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        implicitHeight: 1
                        color: "#20FFFFFF"
                    }

                    // Compact quick controls, matching the Tailnet peer-card spacing.
                    GridLayout {
                        Layout.fillWidth: true
                        columns: 2
                        columnSpacing: 8
                        rowSpacing: 8

                        WifiToggle {}
                        BluetoothToggle {}
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        radius: 12
                        color: "#12FFFFFF"
                        implicitHeight: levelsColumn.implicitHeight + 24

                        ColumnLayout {
                            id: levelsColumn
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.leftMargin: 14
                            anchors.rightMargin: 14
                            spacing: 10

                            StyledText {
                                text: "Levels"
                                font.pixelSize: 11
                                font.bold: true
                                color: "#CFC9D9"
                            }

                            BrightnessSlider {}
                            VolumeSlider {}
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        radius: 12
                        color: "#12FFFFFF"
                        implicitHeight: powerProfile.implicitHeight + 24

                        PowerProfileSelector {
                            id: powerProfile
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.leftMargin: 14
                            anchors.rightMargin: 14
                        }
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        spacing: 8

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 6

                            StyledText {
                                text: "Notifications"
                                font.pixelSize: 12
                                font.bold: true
                                color: "#CFC9D9"
                            }

                            StyledText {
                                text: Notifications.count > 0 ? Notifications.count : ""
                                font.pixelSize: 10
                                color: "#8A8497"
                            }

                            Item { Layout.fillWidth: true }

                            Rectangle {
                                visible: Notifications.count > 0
                                implicitWidth: clearLabel.implicitWidth + 18
                                implicitHeight: 22
                                radius: 6
                                color: clearMouse.containsMouse ? "#24FFFFFF" : "#14FFFFFF"

                                Behavior on color {
                                    ColorAnimation { duration: 120 }
                                }

                                StyledText {
                                    id: clearLabel
                                    anchors.centerIn: parent
                                    text: "Clear all"
                                    font.pixelSize: 10
                                    color: "#CFC9D9"
                                }

                                MouseArea {
                                    id: clearMouse
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: Notifications.clearAll()
                                }
                            }
                        }

                        Item {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            visible: Notifications.count === 0

                            ColumnLayout {
                                anchors.centerIn: parent
                                spacing: 6

                                StyledText {
                                    Layout.alignment: Qt.AlignHCenter
                                    text: "󰂚"
                                    font.pixelSize: 26
                                    color: "#3A3A44"
                                }

                                StyledText {
                                    Layout.alignment: Qt.AlignHCenter
                                    text: "No notifications"
                                    font.pixelSize: 11
                                    color: "#6A6475"
                                }
                            }
                        }

                        ListView {
                            visible: Notifications.count > 0
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            clip: true
                            spacing: 8
                            model: Notifications.list
                            boundsBehavior: Flickable.StopAtBounds

                            delegate: Rectangle {
                                id: notificationCard
                                required property var modelData

                                width: ListView.view.width
                                implicitHeight: notificationContent.implicitHeight + 20
                                radius: 12
                                color: notificationMouse.containsMouse ? "#1CFFFFFF" : "#12FFFFFF"

                                readonly property color urgencyColor: modelData.urgency === NotificationUrgency.Critical ? "#F44336" : "#6A6475"

                                Behavior on color {
                                    ColorAnimation { duration: 120 }
                                }

                                Rectangle {
                                    anchors.left: parent.left
                                    anchors.top: parent.top
                                    anchors.bottom: parent.bottom
                                    anchors.margins: 8
                                    width: 3
                                    radius: 2
                                    color: notificationCard.urgencyColor
                                }

                                MouseArea {
                                    id: notificationMouse
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    acceptedButtons: Qt.NoButton
                                }

                                RowLayout {
                                    id: notificationContent
                                    anchors.left: parent.left
                                    anchors.right: parent.right
                                    anchors.verticalCenter: parent.verticalCenter
                                    anchors.leftMargin: 16
                                    anchors.rightMargin: 12
                                    spacing: 11

                                    Rectangle {
                                        Layout.alignment: Qt.AlignTop
                                        Layout.preferredWidth: 38
                                        Layout.preferredHeight: 38
                                        radius: 10
                                        color: "#16FFFFFF"

                                        StyledText {
                                            anchors.centerIn: parent
                                            text: (notificationCard.modelData.appName || "N").charAt(0).toUpperCase()
                                            font.pixelSize: 15
                                            font.bold: true
                                            color: "#CFC9D9"
                                        }
                                    }

                                    ColumnLayout {
                                        Layout.fillWidth: true
                                        spacing: 3

                                        RowLayout {
                                            Layout.fillWidth: true
                                            spacing: 6

                                            StyledText {
                                                text: notificationCard.modelData.appName || "Notification"
                                                font.pixelSize: 9
                                                font.bold: true
                                                color: "#8A8497"
                                                Layout.fillWidth: true
                                                elide: Text.ElideRight
                                            }

                                            StyledText {
                                                text: "✕"
                                                font.pixelSize: 11
                                                color: dismissMouse.containsMouse ? "#F7F1FF" : "#6A6475"

                                                MouseArea {
                                                    id: dismissMouse
                                                    anchors.fill: parent
                                                    anchors.margins: -6
                                                    hoverEnabled: true
                                                    cursorShape: Qt.PointingHandCursor
                                                    onClicked: Notifications.dismiss(notificationCard.modelData)
                                                }
                                            }
                                        }

                                        StyledText {
                                            text: notificationCard.modelData.summary || ""
                                            font.pixelSize: 12
                                            font.bold: true
                                            color: "#F7F1FF"
                                            Layout.fillWidth: true
                                            wrapMode: Text.Wrap
                                            maximumLineCount: 2
                                            elide: Text.ElideRight
                                            visible: text.length > 0
                                        }

                                        StyledText {
                                            text: notificationCard.modelData.body || ""
                                            font.pixelSize: 10
                                            color: "#B0AABB"
                                            Layout.fillWidth: true
                                            wrapMode: Text.Wrap
                                            maximumLineCount: 4
                                            elide: Text.ElideRight
                                            visible: text.length > 0
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
