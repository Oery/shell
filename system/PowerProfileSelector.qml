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
            color: '#4CAF50'
        },
        {
            value: PowerProfile.Balanced,
            label: "Balanced",
            icon: "󰓅",
            color: '#2196F3'
        },
        {
            value: PowerProfile.Performance,
            label: "Perf",
            icon: "󱐋",
            color: '#F44336'
        }
    ]

    StyledText {
        text: "Power Profile"
        font.pixelSize: 12
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
                implicitHeight: 40
                radius: 10
                opacity: available ? 1.0 : 0.4
                color: selected ? modelData.color : (mouse.containsMouse ? '#24FFFFFF' : '#14FFFFFF')

                Behavior on color {
                    ColorAnimation {
                        duration: 130
                    }
                }

                ColumnLayout {
                    anchors.centerIn: parent
                    spacing: 1

                    StyledText {
                        Layout.alignment: Qt.AlignHCenter
                        text: seg.modelData.icon
                        font.pixelSize: 15
                        color: seg.selected ? '#FFFFFF' : '#CFC9D9'
                    }

                    StyledText {
                        Layout.alignment: Qt.AlignHCenter
                        text: seg.modelData.label
                        font.pixelSize: 9
                        color: seg.selected ? '#FFFFFF' : '#8A8497'
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
