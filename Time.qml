import QtQuick
import Quickshell
pragma Singleton

Singleton {
    id: root

    readonly property string time: {
        let s = clock.date.toLocaleString(Qt.locale("en_EN"), "dddd MMMM dd | HH:mm");
        return s.charAt(0).toUpperCase() + s.slice(1);
    }

    SystemClock {
        id: clock

        precision: SystemClock.Seconds
    }

}
