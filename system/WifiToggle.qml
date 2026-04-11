import QtQuick
import QtQuick.Layouts
import Quickshell.Io
import qs.utils

Item {
    id: root
    property bool wifiEnabled: false
    height: 32

    RowLayout {
        anchors.fill: parent
        spacing: 8

        StyledText {
            text: "Wi-Fi"
            font.pixelSize: 12
        }

        Item { Layout.fillWidth: true }

        Rectangle {
            width: 44
            height: 24
            radius: 12
            color: root.wifiEnabled ? '#4CAF50' : '#666666'

            Rectangle {
                width: 20
                height: 20
                radius: 10
                color: 'white'
                anchors.left: parent.left
                anchors.leftMargin: root.wifiEnabled ? 22 : 2
                anchors.verticalCenter: parent.verticalCenter

                Behavior on anchors.leftMargin { NumberAnimation { duration: 150 } }
            }

            MouseArea {
                anchors.fill: parent
                onClicked: toggleWifi()
            }
        }
    }

    function toggleWifi() {
        wifiToggle.running = true;
    }

    Timer {
        interval: 3000
        repeat: true
        running: true
        onTriggered: wifiCheck.running = true
    }

    Process {
        id: wifiCheck
        command: ["bash", "-c", "nmcli -t -f NAME connection show --active | grep -q . && echo on || echo off"]
        running: false

        stdout: StdioCollector {
            onStreamFinished: {
                root.wifiEnabled = this.text.trim() === "on";
            }
        }
    }

    Process {
        id: wifiToggle
        command: ["bash", "-c", "if nmcli -t -f NAME connection show --active | grep -q .; then nmcli radio wifi off; else nmcli radio wifi on; fi"]
        running: false

        onRunningChanged: if (!running) wifiCheck.running = true
    }

    Component.onCompleted: wifiCheck.running = true
}
