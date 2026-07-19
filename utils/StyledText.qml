import QtQuick
import Quickshell

Text {
    text: String
    color: '#F7F1FF'
    font.family: "JetBrains Mono"
    font.weight: 400
    // Call sites override font.pixelSize, so the default has to be a pixel size
    // too — setting both here makes Qt discard the point size and warn on every
    // instance. 13px matches the previous pointSize 10 exactly at scale 1.
    font.pixelSize: 13
}
