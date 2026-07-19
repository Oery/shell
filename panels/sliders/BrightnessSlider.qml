import Quickshell.Io
import QtQuick
import QtQuick.Layouts
import qs.utils

RowLayout {
    id: root
    Layout.fillWidth: true
    spacing: 12

    StyledText {
        text: brightnessSlider.value < 34 ? "󰃞" : (brightnessSlider.value < 67 ? "󰃟" : "󰃠")
        font.pixelSize: 17
        color: '#FFC107'
        Layout.preferredWidth: 20
        horizontalAlignment: Text.AlignHCenter
    }

    StyledSlider {
        id: brightnessSlider
        Layout.fillWidth: true
        from: 1
        to: 100
        value: 50
        accent: '#FFC107'

        // Only react to user drags, not to the initial hardware read.
        onMoved: brightnessDebounce.restart()
    }

    StyledText {
        text: Math.round(brightnessSlider.value) + "%"
        font.pixelSize: 11
        color: '#AAAAAA'
        Layout.preferredWidth: 32
        horizontalAlignment: Text.AlignRight
    }

    Timer {
        id: brightnessDebounce
        interval: 60
        onTriggered: setBrightness.running = true
    }

    Process {
        id: setBrightness
        command: ["brightnessctl", "s", Math.round(brightnessSlider.value) + "%"]
        running: false
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

    Component.onCompleted: brightnessRead.running = true
}
