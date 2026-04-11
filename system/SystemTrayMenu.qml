import QtQuick
import QtQuick.Layouts
import Quickshell
import QtQuick.Controls

// Custom menu component for system tray items
// This provides better styling than the default QsMenu
Rectangle {
    id: customMenu
    
    property var menuModel
    property var anchorItem
    
    visible: menuModel && menuModel.items.length > 0
    color: '#d8080808'
    border.color: '#40FFFFFF'
    border.width: 1
    radius: 6
    
    width: 200
    height: Math.min(menuColumn.implicitHeight + 16, 300)
    
    Column {
        id: menuColumn
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.margins: 8
        spacing: 2
        
        Repeater {
            model: customMenu.menuModel ? customMenu.menuModel.items : []
            
            Rectangle {
                id: menuItem
                width: parent.width
                height: 28
                color: "transparent"
                radius: 4
                
                Text {
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.leftMargin: 8
                    text: modelData.text || ""
                    color: '#F7F1FF'
                    font.family: "JetBrains Mono"
                    font.pixelSize: 11
                }
                
                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    
                    onEntered: parent.color = '#20FFFFFF'
                    onExited: parent.color = "transparent"
                    onPressed: parent.color = '#40FFFFFF'
                    onReleased: parent.color = containsMouse ? '#20FFFFFF' : "transparent"
                    onClicked: {
                        if (modelData.trigger) {
                            modelData.trigger();
                        }
                        customMenu.visible = false;
                    }
                }
            }
        }
    }
}
