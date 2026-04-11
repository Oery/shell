import Quickshell.Services.UPower
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import qs.utils

Item {
    height: 60

    ColumnLayout {
        anchors.fill: parent
        spacing: 4

        StyledText {
            text: "Power Profile"
            font.pixelSize: 12
        }

        RowLayout {
            spacing: 8

            Repeater {
                model: ["power-saver", "balanced", "performance"]

                delegate: Rectangle {
                    Layout.minimumWidth: 80
                    height: 32
                    radius: 4
                    color: PowerProfiles.profile === modelData ? getColor(modelData) : '#333333'
                    border.color: PowerProfiles.profile === modelData ? getColor(modelData) : '#40FFFFFF'
                    border.width: 1

                    StyledText {
                        anchors.centerIn: parent
                        text: getLabel(modelData)
                        font.pixelSize: 10
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            if (modelData === "performance" && !PowerProfiles.hasPerformanceProfile) {
                                return;
                            }
                            PowerProfiles.profile = modelData;
                        }
                    }
                }
            }
        }
    }

    function getColor(profile) {
        if (profile === "power-saver") return '#4CAF50';
        if (profile === "performance") return '#F44336';
        return '#2196F3';
    }

    function getLabel(profile) {
        if (profile === "power-saver") return "Saver";
        if (profile === "performance") return "Perf";
        return "Balanced";
    }
}
