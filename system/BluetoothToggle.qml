import QtQuick
import QtQuick.Layouts
import Quickshell.Io
import qs.utils

Item {
    id: root
    property bool bluetoothEnabled: false
    height: 32

    RowLayout {
        anchors.fill: parent
        spacing: 8

        StyledText {
            text: "Bluetooth"
            font.pixelSize: 12
        }

        Item { Layout.fillWidth: true }

        Rectangle {
            width: 44
            height: 24
            radius: 12
            color: root.bluetoothEnabled ? '#4CAF50' : '#666666'

            Rectangle {
                width: 20
                height: 20
                radius: 10
                color: 'white'
                anchors.left: parent.left
                anchors.leftMargin: root.bluetoothEnabled ? 22 : 2
                anchors.verticalCenter: parent.verticalCenter

                Behavior on anchors.leftMargin { NumberAnimation { duration: 150 } }
            }

            MouseArea {
                anchors.fill: parent
                onClicked: toggleBluetooth()
            }
        }
    }

    function toggleBluetooth() {
        bluetoothToggle.running = true;
    }

    Timer {
        interval: 3000
        repeat: true
        running: true
        onTriggered: bluetoothCheck.running = true
    }

    Process {
        id: bluetoothCheck
        command: ["bash", "-c", "rfkill list bluetooth | grep -q 'Soft blocked: no' && echo on || echo off"]
        running: false

        stdout: StdioCollector {
            onStreamFinished: {
                root.bluetoothEnabled = this.text.trim() === "on";
            }
        }
    }

    Process {
        id: bluetoothToggle
        command: ["bash", "-c", "if rfkill list bluetooth | grep -q 'Soft blocked: no'; then rfkill block bluetooth; else rfkill unblock bluetooth; fi"]
        running: false

        onRunningChanged: if (!running) bluetoothCheck.running = true
    }

    Component.onCompleted: bluetoothCheck.running = true
}
