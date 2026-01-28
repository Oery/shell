import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Services.Notifications
import Quickshell.Widgets

PopupWindow {
    id: popup

    required property var notification

    implicitWidth: 350
    implicitHeight: 400
    color: "#2a2a2a" // Make background visible
    visible: true

    Component.onCompleted: {
        console.log("NotificationPopup Component.onCompleted");
        console.log("Window properties:");
        console.log("- width:", implicitWidth);
        console.log("- height:", implicitHeight);
        console.log("- color:", color);
        console.log("- visible:", visible);
        console.log("Notification object:", notification ? "exists" : "null");

        if (notification) {
            console.log("Notification summary:", notification.summary);
            console.log("Notification body:", notification.body);
        }
    }

    // Simple visible content to test if window appears
    StyledText {
        anchors.centerIn: parent
        text: "📢 Notification Test"
        font.pixelSize: 20
        color: "#ffffff"
    }

    Timer {
        id: autoHideTimer
        interval: 3000
        running: true

        onTriggered: {
            console.log("Auto-hide timer triggered");
            popup.destroy();
        }
    }

    MouseArea {
        anchors.fill: parent
        onClicked: {
            console.log("Window clicked");
            popup.destroy();
        }
    }
}
