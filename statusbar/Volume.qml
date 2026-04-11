import QtQuick
import Quickshell.Services.Pipewire
import qs.utils

StyledText {
    id: root

    PwObjectTracker {
        objects: [Pipewire.defaultAudioSink]
    }

    property real volumeVal: Pipewire.defaultAudioSink?.audio?.volume ?? 0
    property bool muted: Pipewire.defaultAudioSink?.audio?.muted ?? false

    text: "Vol: " + (muted ? "Muted" : Math.round(volumeVal * 100) + "%") + " | "
}
