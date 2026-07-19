import Quickshell.Services.Pipewire
import QtQuick
import QtQuick.Layouts
import qs.utils

RowLayout {
    id: root
    Layout.fillWidth: true
    spacing: 12

    property bool muted: Pipewire.defaultAudioSink?.audio?.muted ?? false

    PwObjectTracker {
        objects: [Pipewire.defaultAudioSink]
    }

    function toggleMute() {
        if (Pipewire.defaultAudioSink?.audio) {
            Pipewire.defaultAudioSink.audio.muted = !Pipewire.defaultAudioSink.audio.muted;
        }
    }

    StyledText {
        text: root.muted ? "󰖁" : (volumeSlider.value < 0.01 ? "󰕿" : (volumeSlider.value < 0.5 ? "󰖀" : "󰕾"))
        font.pixelSize: 17
        color: root.muted ? '#F44336' : '#4CAF50'
        Layout.preferredWidth: 20
        horizontalAlignment: Text.AlignHCenter

        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: root.toggleMute()
        }
    }

    StyledSlider {
        id: volumeSlider
        Layout.fillWidth: true
        from: 0
        to: 1
        stepSize: 0.01
        value: Pipewire.defaultAudioSink?.audio?.volume ?? 0.5
        accent: root.muted ? '#666666' : '#4CAF50'
        opacity: root.muted ? 0.5 : 1.0

        onMoved: {
            if (Pipewire.defaultAudioSink?.audio) {
                Pipewire.defaultAudioSink.audio.volume = value;
                if (Pipewire.defaultAudioSink.audio.muted)
                    Pipewire.defaultAudioSink.audio.muted = false;
            }
        }
    }

    StyledText {
        text: Math.round(volumeSlider.value * 100) + "%"
        font.pixelSize: 11
        color: '#AAAAAA'
        Layout.preferredWidth: 32
        horizontalAlignment: Text.AlignRight
    }
}
