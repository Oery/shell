pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import qs.utils
import qs.panels.sliders
import qs.system

Singleton {
    id: rightpanel

    property bool isVisible: false

    function toggle() {
        isVisible = !isVisible;
    }

    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: rightPanel
            required property var modelData

            screen: modelData
            visible: rightpanel.isVisible

            anchors {
                top: true
                right: true
                bottom: true
            }

            implicitWidth: 350
            color: 'transparent'

            exclusiveZone: 0
            focusable: true

            Rectangle {
                color: '#E5080808'
                anchors.fill: parent
                anchors.margins: 5
                radius: 4

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
                    anchors.margins: 10
                    spacing: 10

                    StyledText {
                        text: "Settings"
                        font.pixelSize: 14
                        font.bold: true
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        implicitHeight: 1
                        color: '#40FFFFFF'
                    }

                    Flickable {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        contentHeight: contentColumn.height
                        clip: true

                        ColumnLayout {
                            id: contentColumn
                            width: parent.width
                            spacing: 20

                            WifiToggle {}

                            BrightnessSlider {}

                            VolumeSlider {}

                            PowerProfileSelector {}

                            BluetoothToggle {}
                        }
                    }
                }
            }
        }
    }
}
