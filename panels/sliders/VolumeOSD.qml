import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Services.Pipewire

PanelWindow {
    id: osdWindow
    exclusiveZone: 0
    width: 300
    height: 80
    // flags: Qt.Popup | Qt.FramelessWindowHint | Qt.WindowStaysOnTopHint
    color: "transparent"
    visible: false

    Rectangle {
        id: bg
        anchors.fill: parent
        radius: 8
        color: "#080808D8"   // semi‐transparent background
        border.color: "#AAA"
        border.width: 1

        Row {
            anchors.centerIn: parent
            spacing: 12

            // icon
            Image {
                id: icon
                source: "volume‐high.svg" // swap based on level/mute
                width: 32; height: 32
            }

            // volume bar or text
            ProgressBar {
                id: volBar
                width: 200
                from: 0
                to: 100
                value: volumePercent
            }
        }
    }

    property real volumePercent: 0
    property bool muted: false

    Timer {
        id: hideTimer
        interval: 1500  // ms
        repeat: false
        onTriggered: osdWindow.visible = false
    }
    //
    PwAudioChannel {
        id: audioChan
        onVolumeChanged: {
            // volume is array maybe, take first channel
            volumePercent = volume * 100
            icon.source = muted ? "volume‐muted.svg"
                                : (volumePercent < 50 ? "volume‐low.svg" : "volume‐high.svg")
            osdWindow.visible = true
            hideTimer.restart()
        }
        onMutedChanged: {
            muted = muted
            icon.source = muted ? "volume‐muted.svg" : icon.source
            osdWindow.visible = true
            hideTimer.restart()
        }
    }
    //
    Component.onCompleted: {
        const scr = ShellRoot.screens[0]
        x = scr.geometry.x + (scr.geometry.width - width)/2
        y = scr.geometry.y + scr.geometry.height*0.85
    }
}
