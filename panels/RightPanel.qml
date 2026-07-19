pragma Singleton

import Quickshell
import Quickshell.Hyprland
import Quickshell.Widgets
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

    // Monitor this panel opened on, captured at open time so it doesn't jump
    // if focus moves elsewhere while it's up.
    property string activeScreen: ""

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
            // Only the focused monitor's instance shows. Otherwise every
            // monitor gets a copy, and their focus grabs cancel each other out.
            visible: rightpanel.isVisible && FocusedScreen.matches(modelData, rightpanel.activeScreen)

            anchors {
                top: true
                right: true
                bottom: true
            }

            implicitWidth: 360
            color: 'transparent'

            exclusiveZone: 0
            focusable: true

            HyprlandFocusGrab {
                windows: [rightPanel]
                active: rightPanel.visible
                onCleared: rightpanel.isVisible = false
            }

            Rectangle {
                id: bg
                color: '#E5080808'
                anchors.fill: parent
                anchors.margins: 5
                radius: 10

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
                    spacing: 16

                    // Header
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 8

                        StyledText {
                            text: "󰒓"
                            font.pixelSize: 16
                            color: '#F7F1FF'
                        }

                        StyledText {
                            text: "Control Center"
                            font.pixelSize: 14
                            font.bold: true
                        }

                        Item {
                            Layout.fillWidth: true
                        }

                        StyledText {
                            text: clock.date.toLocaleString(Qt.locale("en_EN"), "ddd HH:mm")
                            font.pixelSize: 11
                            color: '#8A8497'
                        }

                        SystemClock {
                            id: clock
                            precision: SystemClock.Minutes
                        }
                    }

                    // Quick toggles
                    GridLayout {
                        Layout.fillWidth: true
                        columns: 2
                        columnSpacing: 10
                        rowSpacing: 10

                        WifiToggle {}
                        BluetoothToggle {}
                    }

                    // Sliders card
                    Rectangle {
                        Layout.fillWidth: true
                        radius: 14
                        color: '#0FFFFFFF'
                        implicitHeight: slidersCol.implicitHeight + 28

                        ColumnLayout {
                            id: slidersCol
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.leftMargin: 14
                            anchors.rightMargin: 14
                            spacing: 14

                            BrightnessSlider {}
                            VolumeSlider {}
                        }
                    }

                    // Power profile card
                    Rectangle {
                        Layout.fillWidth: true
                        radius: 14
                        color: '#0FFFFFFF'
                        implicitHeight: powerCol.implicitHeight + 28

                        PowerProfileSelector {
                            id: powerCol
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.leftMargin: 14
                            anchors.rightMargin: 14
                        }
                    }

                    // Notifications
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
                                color: '#CFC9D9'
                            }

                            StyledText {
                                text: Notifications.count > 0 ? Notifications.count : ""
                                font.pixelSize: 10
                                color: '#8A8497'
                            }

                            Item {
                                Layout.fillWidth: true
                            }

                            Rectangle {
                                visible: Notifications.count > 0
                                implicitWidth: clearLabel.implicitWidth + 18
                                implicitHeight: 22
                                radius: 6
                                color: clearMouse.containsMouse ? '#24FFFFFF' : '#14FFFFFF'

                                Behavior on color {
                                    ColorAnimation {
                                        duration: 120
                                    }
                                }

                                StyledText {
                                    id: clearLabel
                                    anchors.centerIn: parent
                                    text: "Clear all"
                                    font.pixelSize: 10
                                    color: '#CFC9D9'
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

                        // Empty state
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
                                    color: '#3A3A44'
                                }

                                StyledText {
                                    Layout.alignment: Qt.AlignHCenter
                                    text: "No notifications"
                                    font.pixelSize: 11
                                    color: '#6A6475'
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
                                id: notifCard
                                required property var modelData

                                width: ListView.view.width
                                implicitHeight: ncontent.implicitHeight + 20
                                radius: 10
                                color: cardMouse.containsMouse ? '#1CFFFFFF' : '#12FFFFFF'

                                Behavior on color {
                                    ColorAnimation {
                                        duration: 120
                                    }
                                }

                                readonly property color urgencyColor: {
                                    if (modelData.urgency === NotificationUrgency.Critical)
                                        return '#F44336';
                                    if (modelData.urgency === NotificationUrgency.Low)
                                        return '#4A4A55';
                                    return '#2196F3';
                                }

                                readonly property string iconSource: {
                                    if (modelData.image && modelData.image.length > 0)
                                        return modelData.image.startsWith("/") ? "file://" + modelData.image : modelData.image;
                                    if (modelData.appIcon && modelData.appIcon.length > 0)
                                        return Quickshell.iconPath(modelData.appIcon, true);
                                    return "";
                                }

                                MouseArea {
                                    id: cardMouse
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    acceptedButtons: Qt.NoButton
                                }

                                // Urgency accent stripe
                                Rectangle {
                                    anchors.left: parent.left
                                    anchors.top: parent.top
                                    anchors.bottom: parent.bottom
                                    anchors.margins: 8
                                    width: 3
                                    radius: 2
                                    color: notifCard.urgencyColor
                                }

                                RowLayout {
                                    id: ncontent
                                    anchors.left: parent.left
                                    anchors.right: parent.right
                                    anchors.verticalCenter: parent.verticalCenter
                                    anchors.leftMargin: 18
                                    anchors.rightMargin: 10
                                    spacing: 10

                                    IconImage {
                                        visible: notifCard.iconSource.length > 0 && status !== Image.Error
                                        source: notifCard.iconSource
                                        Layout.preferredWidth: 26
                                        Layout.preferredHeight: 26
                                        Layout.alignment: Qt.AlignTop
                                        asynchronous: true
                                    }

                                    ColumnLayout {
                                        Layout.fillWidth: true
                                        spacing: 2

                                        RowLayout {
                                            Layout.fillWidth: true
                                            spacing: 6

                                            StyledText {
                                                text: notifCard.modelData.appName || "Notification"
                                                font.pixelSize: 9
                                                font.bold: true
                                                color: '#8A8497'
                                                Layout.fillWidth: true
                                                elide: Text.ElideRight
                                            }

                                            StyledText {
                                                text: "✕"
                                                font.pixelSize: 11
                                                color: dismissMouse.containsMouse ? '#F44336' : '#6A6475'

                                                MouseArea {
                                                    id: dismissMouse
                                                    anchors.fill: parent
                                                    anchors.margins: -6
                                                    hoverEnabled: true
                                                    cursorShape: Qt.PointingHandCursor
                                                    onClicked: Notifications.dismiss(notifCard.modelData)
                                                }
                                            }
                                        }

                                        StyledText {
                                            text: notifCard.modelData.summary || ""
                                            font.pixelSize: 12
                                            font.bold: true
                                            color: '#F7F1FF'
                                            Layout.fillWidth: true
                                            wrapMode: Text.Wrap
                                            maximumLineCount: 2
                                            elide: Text.ElideRight
                                            visible: text.length > 0
                                        }

                                        StyledText {
                                            text: notifCard.modelData.body || ""
                                            font.pixelSize: 10
                                            color: '#B0AABB'
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
