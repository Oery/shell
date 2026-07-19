import QtQuick
import Quickshell.Io

ToggleTile {
    id: root

    property bool bluetoothEnabled: false

    icon: bluetoothEnabled ? "󰂯" : "󰂲"
    label: "Bluetooth"
    sublabel: bluetoothEnabled ? "On" : "Off"
    active: bluetoothEnabled
    accent: '#3F51B5'

    onToggled: bluetoothToggle.running = true

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

        onRunningChanged: if (!running)
            bluetoothCheck.running = true
    }

    Component.onCompleted: bluetoothCheck.running = true
}
