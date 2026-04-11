import QtQuick
import Quickshell
import Quickshell.Io
pragma Singleton

Singleton {
    id: root

    property string wallpaperPath: ''

    property bool wallpaperSelectorVisible: false
    property string originalWallpaperPath: ''

    property bool configLoaded: false

    Timer {
        id: readTimer
        interval: 1
        repeat: false
        onTriggered: readConfig.running = true
    }

    Timer {
        id: writeTimer
        interval: 100
        repeat: false
        onTriggered: writeConfig.running = true
    }

    Process {
        id: writeConfig
        command: ["bash", "-c", "echo '{\"wallpaperPath\":\"" + root.wallpaperPath + "\"}' > /home/oery/.config/quickshell/oery/config.json"]
        running: false
    }

    Process {
        id: readConfig
        command: ["bash", "-c", "cat /home/oery/.config/quickshell/oery/config.json"]
        running: false

        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    var data = JSON.parse(this.text.trim());
                    if (data.wallpaperPath) {
                        root.wallpaperPath = data.wallpaperPath;
                    }
                } catch (e) {}
                root.configLoaded = true;
            }
        }
    }

    Component.onCompleted: {
        readTimer.running = true;
    }

    onWallpaperPathChanged: {
        if (configLoaded) {
            writeTimer.restart();
        }
    }
}
