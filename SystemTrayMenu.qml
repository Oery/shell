import QtQuick
import QtQuick.Layouts
import Quickshell

QsMenuAnchor {
    // anchor.window: parentwindow
    // ColumnLayout {
    // 	Repeater {
    // 		model: tray_menu.model
    // 		delegate: AbstractButton {
    // 			required property var modelData
    // 			contentItem: StyledText {
    // 				text: modelData.text
    // 			}
    // 		}
    // 	}
    // }

    // model: ObjectModel<QsMenuEntry>
    id: tray_menu
}
