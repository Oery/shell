import QtQuick
import Quickshell.Io
import qs.utils

StyledText {
    id: root

    property string wifiText: ""

    Process {
        id: wifiProcess
        command: ["nmcli", "-t", "-f", "NAME,TYPE,STATE", "connection", "show", "--active"]
        running: true

        stdout: StdioCollector {
            onStreamFinished: {
                const lines = this.text.trim().split('\n');
                for (const line of lines) {
                    const parts = line.split(':');
                    if (parts.length >= 3 && parts[1] === '802-11-wireless' && parts[2] === 'activated') {
                        root.wifiText = parts[0];
                        return;
                    }
                }
                root.wifiText = "";
            }
        }
    }

    Timer {
        interval: 5000
        repeat: true
        running: true
        onTriggered: wifiProcess.running = true
    }

    text: root.wifiText ? root.wifiText + " | " : ""
}
