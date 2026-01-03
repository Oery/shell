import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import Quickshell.Services.SystemTray

RowLayout {
    id: root
    
    Row {

        Repeater {
            model: SystemTray.items
            
            Rectangle {
                id: itemContainer
                
                required property var modelData
                property var item: modelData
                
                width: 24
                height: 24
                color: "transparent"
                radius: 4
                
                Behavior on color {
                    ColorAnimation { duration: 100 }
                }
                
                Image {
                    id: directIcon
                    anchors.centerIn: parent
                    source: item.icon || ""
                    sourceSize.width: 16
                    sourceSize.height: 16
                    smooth: true
                    asynchronous: true
                    visible: status === Image.Ready && source.toString() !== ""
                }
                
                Text {
                    anchors.centerIn: parent
                    visible: !directIcon.visible
                    text: item.tooltipTitle[0]
                    color: '#F7F1FF'
                    font.family: "JetBrains Mono"
                    font.pixelSize: 11
                    font.bold: true
                }
                
                MouseArea {
                    id: itemMouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                    acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
                    
                    onEntered: {
                        parent.color = '#20FFFFFF';
                        const tooltipText = item.title || item.id || "Unknown";
                        tooltipPopup.show(tooltipText, itemContainer);
                    }
                    
                    onExited: {
                        parent.color = "transparent";
                        tooltipPopup.close();
                    }
                    
                    onClicked: event => {
                        if (event.button == Qt.LeftButton) {
                            item.activate();
                        } else if (event.button == Qt.MiddleButton) {
                            item.secondaryActivate();
                        } else if (event.button == Qt.RightButton) {
                            menuAnchor.open();
                        }
                    }
                    
                    QsMenuAnchor {
                        id: menuAnchor
                        menu: item.menu
                        anchor.window: itemContainer.QsWindow.window
                        anchor.adjustment: PopupAdjustment.Flip
                        anchor.onAnchoring: {
                            const window = itemContainer.QsWindow.window;
                            const widgetRect = window.contentItem.mapFromItem(itemContainer, 0, itemContainer.height, itemContainer.width, itemContainer.height);
                            menuAnchor.anchor.rect = widgetRect;
                        }
                    }
                }
                

            }
        }
    }
    
    // Popup {
    //     id: tooltipPopup
    //     visible: false
    //
    //     background: Rectangle {
    //         color: '#d8080808'
    //         border.color: '#40FFFFFF'
    //         border.width: 1
    //         radius: 4
    //     }
    //
    //     contentItem: Text {
    //         id: tooltipContent
    //         color: '#F7F1FF'
    //         font.family: "JetBrains Mono"
    //         font.pixelSize: 11
    //     }
    //
    //     function show(text, parentItem) {
    //         tooltipContent.text = text;
    //
    //         // Position relative to parent item
    //         var pos = parentItem.mapToItem(null, 0, parentItem.height);
    //         x = pos.x + (parentItem.width - width) / 2;
    //         y = pos.y + 6;
    //
    //         open();
    //     }
    // }
    
}
