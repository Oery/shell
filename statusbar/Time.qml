pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Services.SystemTray

Singleton {
    id: root

    readonly property string time: {
        let s = clock.date.toLocaleString(Qt.locale("en_EN"), "dd/MM/yyyy | HH:mm");

        if (SystemTray.items.values.length > 0) {
            s = s.concat(" ", "|");
        }

        return s;
    }

    SystemClock {
        id: clock
        precision: SystemClock.Seconds
    }
}
