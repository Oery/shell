import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import Quickshell.Services.SystemTray

RowLayout {
    RowLayout {
        id: tray

        visible: false

        Repeater {
            model: SystemTray.items

            MouseArea {
                id: delegate

                required property SystemTrayItem modelData
                property alias item: delegate.modelData

                Layout.fillHeight: true
                implicitWidth: stext.implicitWidth
                acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
                hoverEnabled: true
                
                propagateComposedEvents: true

                onClicked: event => {
                    if (event.button == Qt.LeftButton) {
                        item.activate();
                    } else if (event.button == Qt.MiddleButton) {
                        item.secondaryActivate();
                    } else if (event.button == Qt.RightButton) {
                        menuAnchor.open();
                    }
                }

                StyledText {
                    id: stext
                    text: item.title ? item.title : "Vesktop"
                    font.underline: delegate.containsMouse
                }

                QsMenuAnchor {
                    id: menuAnchor

                    menu: item.menu
                    anchor.window: delegate.QsWindow.window
                    anchor.adjustment: PopupAdjustment.Flip
                    anchor.onAnchoring: {
                        const window = delegate.QsWindow.window;
                        const widgetRect = window.contentItem.mapFromItem(delegate, 0, delegate.height, delegate.width, delegate.height);
                        menuAnchor.anchor.rect = widgetRect;
                    }
                }

            }

        }

    }

    AbstractButton {
        id: tray_btn
        onClicked: tray.visible = !tray.visible

        contentItem: StyledText {
            text: tray.visible ? ">" : "<"
        }
    }

    MouseArea {
        propagateComposedEvents: true

        anchors.fill: parent
        hoverEnabled: true
        onEntered: tray.visible = true
        onExited: tray.visible = false
    }
}
