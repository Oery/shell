import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland

Repeater {
    model: Hyprland.workspaces

    delegate: AbstractButton {
        required property var modelData

        onClicked: modelData.activate()

        contentItem: StyledText {
            text: modelData.id
            font.bold: modelData.id == Hyprland.focusedWorkspace.id
            font.underline: modelData.id == Hyprland.focusedWorkspace.id
        }
    }
}
