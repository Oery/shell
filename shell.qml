import QtQuick
import Quickshell
import Quickshell.Io

Scope {
    Bar {}
    Notifications {}

    IpcHandler {
        target: "leftpanel"

        function toggle(): void {
            SidePanel.toggle();
        }
    }
}
