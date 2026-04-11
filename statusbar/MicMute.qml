import QtQuick
import Quickshell.Services.Pipewire
import qs.utils

StyledText {
    id: root

    PwObjectTracker {
        objects: [Pipewire.defaultAudioSource]
    }

    property bool muted: Pipewire.defaultAudioSource?.audio?.muted ?? false

    text: muted ? "  | " : ""
}
