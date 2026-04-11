import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.utils

Scope {
    Variants {
        model: Quickshell.screens

        PanelWindow {
            required property var modelData

            screen: modelData

            implicitWidth: modelData.width
            implicitHeight: modelData.height

            color: 'transparent'
            exclusionMode: ExclusionMode.Ignore

            aboveWindows: false
            WlrLayershell.layer: WlrLayer.Background

            Image {
                anchors.fill: parent
                source: Config.wallpaperPath
                fillMode: Image.PreserveAspectCrop
                asynchronous: true
                smooth: true
                mipmap: true
                retainWhileLoading: true
                visible: Config.wallpaperPath !== ''
            }
        }
    }
}
