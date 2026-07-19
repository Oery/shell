pragma Singleton

import Quickshell
import Quickshell.Services.Notifications
import QtQuick

Singleton {
    id: root

    // Persistent (tracked) notification history, newest first.
    property var list: []
    readonly property int count: list.length

    // Emitted when a new notification arrives, so the shell can show a
    // transient popup without affecting the persisted history.
    signal popup(var notif)

    // On reload, kept notifications are re-emitted; suppress popups for those
    // replays by only popping up once past this initial grace period.
    property bool ready: false
    Timer {
        running: true
        interval: 600
        onTriggered: root.ready = true
    }

    NotificationServer {
        id: server
        keepOnReload: true
        bodySupported: true
        imageSupported: true

        onNotification: notif => {
            // Track it so it survives past the popup and stays in history.
            notif.tracked = true;
            root.list = [notif, ...root.list];

            notif.closed.connect(() => {
                root.list = root.list.filter(n => n !== notif);
            });

            if (root.ready)
                root.popup(notif);
        }
    }

    function dismiss(notif) {
        if (notif)
            notif.dismiss();
    }

    function clearAll() {
        const copy = root.list.slice();
        for (const n of copy) {
            n.dismiss();
        }
    }
}
