import QtQuick
import QtQuick.Controls

// Soft level control matching the translucent side-panel cards.
Slider {
    id: control

    property color accent: '#E8E8E2'

    implicitHeight: 20

    background: Rectangle {
        x: control.leftPadding
        y: control.topPadding + control.availableHeight / 2 - height / 2
        implicitWidth: 120
        width: control.availableWidth
        height: 5
        radius: 3
        color: '#2EFFFFFF'

        Rectangle {
            width: control.visualPosition * parent.width
            height: parent.height
            radius: 3
            color: control.accent

            Behavior on color {
                ColorAnimation {
                    duration: 120
                }
            }
        }
    }

    handle: Rectangle {
        x: control.leftPadding + control.visualPosition * (control.availableWidth - width)
        y: control.topPadding + control.availableHeight / 2 - height / 2
        implicitWidth: 14
        implicitHeight: 14
        radius: 7
        color: '#FFFFFF'
        scale: control.pressed ? 1.2 : 1.0

        Behavior on scale {
            NumberAnimation {
                duration: 100
                easing.type: Easing.OutCubic
            }
        }
    }
}
