import Quickshell.Services.Pipewire
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import qs.utils

Item {
    id: root
    height: 80
    implicitHeight: 80

    PwObjectTracker {
        objects: [Pipewire.defaultAudioSink]
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 4

        RowLayout {
            spacing: 8

            StyledText {
                id: volumeValueText
                text: Math.round(sliderValue * 100) + "%"
                font.pixelSize: 11
                color: '#AAAAAA'
            }

            Item {
                Layout.fillWidth: true
            }

            Rectangle {
                id: muteButton
                width: 28
                height: 28
                radius: 4
                color: muted ? '#F44336' : 'transparent'
                border.color: muted ? '#F44336' : '#40FFFFFF'
                border.width: 1

                StyledText {
                    anchors.centerIn: parent
                    text: muted ? "M" : "M"
                    font.pixelSize: 14
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: toggleMute()
                }
            }
        }

        RowLayout {
            spacing: 8

            StyledText {
                text: "Low"
                font.pixelSize: 11
            }

            Slider {
                id: volumeSlider
                Layout.fillWidth: true
                Layout.preferredHeight: 24
                from: 0
                to: 1
                stepSize: 0.01
                value: muted ? 0 : (Pipewire.defaultAudioSink?.audio?.volume ?? 0.5)

                onValueChanged: {
                    volumeValueText.text = Math.round(value * 100) + "%";
                    volumeDebounce.restart();
                }
            }

            StyledText {
                text: "High"
                font.pixelSize: 11
            }
        }
    }

    property real sliderValue: 0.5
    property bool muted: Pipewire.defaultAudioSink?.audio?.muted ?? false

    function toggleMute() {
        if (Pipewire.defaultAudioSink?.audio) {
            Pipewire.defaultAudioSink.audio.muted = !Pipewire.defaultAudioSink.audio.muted;
        }
    }

    Timer {
        id: volumeDebounce
        interval: 50
        onTriggered: {
            sliderValue = volumeSlider.value;
            if (Pipewire.defaultAudioSink?.audio) {
                Pipewire.defaultAudioSink.audio.volume = volumeSlider.value;
            }
        }
    }
}
