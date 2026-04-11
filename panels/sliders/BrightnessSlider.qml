import Quickshell.Io
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import qs.utils

Item {
    id: root

    readonly property real brightnessValue: 50
    height: 80
    implicitHeight: 80

    ColumnLayout {
        anchors.fill: parent
        spacing: 4

        RowLayout {
            spacing: 8

            StyledText {
                text: "Brightness"
                font.pixelSize: 12
            }

            Item {
                Layout.fillWidth: true
            }

            StyledText {
                id: brightnessValueText
                text: Math.round(brightnessSlider.value) + "%"
                font.pixelSize: 11
                color: '#AAAAAA'
            }
        }

        RowLayout {
            spacing: 8

            StyledText {
                text: "Low"
                font.pixelSize: 11
            }

            Slider {
                id: brightnessSlider
                Layout.fillWidth: true
                Layout.preferredHeight: 24
                from: 1
                to: 100
                value: 50

                onValueChanged: {
                    brightnessValueText.text = Math.round(value) + "%";
                    brightnessDebounce.restart();
                }
            }

            StyledText {
                text: "High"
                font.pixelSize: 11
            }
        }

        Timer {
            id: brightnessDebounce
            interval: 100
            onTriggered: setBrightness.running = true
        }

        Process {
            id: setBrightness
            command: ["brightnessctl", "s", Math.round(brightnessSlider.value) + "%"]
            running: false
        }

        Component.onCompleted: {
            brightnessRead.running = true;
        }

        Process {
            id: brightnessRead
            command: ["sh", "-c", "brightnessctl g; brightnessctl m"]
            running: false

            stdout: StdioCollector {
                onStreamFinished: {
                    var lines = this.text.trim().split('\n');
                    if (lines.length >= 2) {
                        var current = parseInt(lines[0]) || 0;
                        var maxVal = parseInt(lines[1]) || 100;
                        if (maxVal > 0) {
                            brightnessSlider.value = Math.round((current / maxVal) * 100);
                        }
                    }
                }
            }
        }
    }
}
