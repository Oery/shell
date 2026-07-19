import QtQuick
import QtQuick.Layouts
import qs.utils

// A quick-settings toggle tile: icon + label + status, tinted when active.
Rectangle {
    id: tile

    property string icon: ""
    property string label: ""
    property string sublabel: ""
    property bool active: false
    property color accent: '#2196F3'

    signal toggled

    Layout.fillWidth: true
    implicitHeight: 58
    radius: 12
    color: active ? accent : (mouse.containsMouse ? '#24FFFFFF' : '#14FFFFFF')

    Behavior on color {
        ColorAnimation {
            duration: 130
        }
    }

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 14
        anchors.rightMargin: 12
        spacing: 11

        StyledText {
            text: tile.icon
            font.pixelSize: 19
            color: tile.active ? '#FFFFFF' : '#CFC9D9'
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 0

            StyledText {
                text: tile.label
                font.pixelSize: 12
                font.bold: true
                color: tile.active ? '#FFFFFF' : '#F7F1FF'
                Layout.fillWidth: true
                elide: Text.ElideRight
            }

            StyledText {
                text: tile.sublabel
                font.pixelSize: 9
                color: tile.active ? '#DCFFFFFF' : '#8A8497'
                Layout.fillWidth: true
                elide: Text.ElideRight
                visible: text.length > 0
            }
        }
    }

    MouseArea {
        id: mouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: tile.toggled()
    }
}
