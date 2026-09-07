import QtQuick
import QtQuick.Layouts
import qs.utils

// Compact quick-setting in the same soft-card language as the side panels.
Rectangle {
    id: tile

    property string icon: ""
    property string label: ""
    property string sublabel: ""
    property bool active: false
    property color accent: '#E8E8E2'

    signal toggled

    Layout.fillWidth: true
    implicitHeight: 50
    radius: 12
    color: mouse.containsMouse ? '#1CFFFFFF' : '#12FFFFFF'
    border.width: 1
    border.color: active ? accent : '#18FFFFFF'

    Behavior on color {
        ColorAnimation {
            duration: 130
        }
    }

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 11
        anchors.rightMargin: 10
        spacing: 9

        StyledText {
            text: tile.icon
            font.pixelSize: 16
            color: tile.active ? tile.accent : '#8A8497'
            Layout.preferredWidth: 20
            Layout.minimumWidth: 20
            Layout.maximumWidth: 20
            horizontalAlignment: Text.AlignHCenter
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 0

            StyledText {
                text: tile.label
                font.pixelSize: 11
                font.bold: true
                font.letterSpacing: 0.3
                color: '#F7F1FF'
                Layout.fillWidth: true
                elide: Text.ElideRight
            }

            StyledText {
                text: tile.sublabel
                font.pixelSize: 8
                font.letterSpacing: 0.7
                color: '#8A8497'
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
