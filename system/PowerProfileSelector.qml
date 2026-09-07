import Quickshell.Services.UPower
import QtQuick
import QtQuick.Layouts
import qs.utils

ColumnLayout {
    id: root
    Layout.fillWidth: true
    spacing: 8

    readonly property var profiles: [
        {
            value: PowerProfile.PowerSaver,
            label: "Saver",
            icon: "󰌪",
            color: '#E8E8E2'
        },
        {
            value: PowerProfile.Balanced,
            label: "Balanced",
            icon: "󰓅",
            color: '#E8E8E2'
        },
        {
            value: PowerProfile.Performance,
            label: "Perf",
            icon: "󱐋",
            color: '#E8E8E2'
        }
    ]

    StyledText {
        text: "Power Profile"
        font.pixelSize: 11
        font.bold: true
        color: '#CFC9D9'
    }

    RowLayout {
        Layout.fillWidth: true
        spacing: 6

        Repeater {
            model: root.profiles

            delegate: Rectangle {
                id: seg
                required property var modelData

                readonly property bool selected: PowerProfiles.profile === modelData.value
                readonly property bool available: modelData.value !== PowerProfile.Performance || PowerProfiles.hasPerformanceProfile

                Layout.fillWidth: true
                implicitHeight: 42
                radius: 10
                opacity: available ? 1.0 : 0.4
                color: selected ? '#28FFFFFF' : (mouse.containsMouse ? '#20FFFFFF' : '#12FFFFFF')
                border.width: 1
                border.color: selected ? modelData.color : 'transparent'

                Behavior on color {
                    ColorAnimation {
                        duration: 130
                    }
                }

                ColumnLayout {
                    anchors.centerIn: parent
                    spacing: 2

                    StyledText {
                        Layout.alignment: Qt.AlignHCenter
                        text: seg.modelData.icon
                        font.pixelSize: 15
                        color: seg.selected ? '#F7F1FF' : '#CFC9D9'
                    }

                    StyledText {
                        Layout.alignment: Qt.AlignHCenter
                        text: seg.modelData.label
                        font.pixelSize: 9
                        font.bold: true
                        color: seg.selected ? '#F7F1FF' : '#8A8497'
                    }
                }

                MouseArea {
                    id: mouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: seg.available ? Qt.PointingHandCursor : Qt.ArrowCursor
                    onClicked: {
                        if (!seg.available)
                            return;
                        PowerProfiles.profile = seg.modelData.value;
                    }
                }
            }
        }
    }
}
