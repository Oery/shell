import QtQuick
import Quickshell.Io

ToggleTile {
    id: root

    property bool wifiEnabled: false

    icon: wifiEnabled ? "󰤨" : "󰤭"
    label: "Wi-Fi"
    sublabel: wifiEnabled ? "ONLINE" : "OFFLINE"
    active: wifiEnabled
    accent: '#E8E8E2'

    onToggled: wifiToggle.running = true

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

        onRunningChanged: if (!running)
            wifiCheck.running = true
    }

    Component.onCompleted: wifiCheck.running = true
}
