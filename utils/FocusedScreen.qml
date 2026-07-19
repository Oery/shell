import Quickshell
import Quickshell.Hyprland
pragma Singleton

// Which monitor a popup panel should open on.
//
// Quickshell 0.3.0's HyprlandMonitor exposes no `.screen`, and its per-monitor
// `focused` flag reads false on every monitor, so `Hyprland.monitorFor()` is
// the only reliable link from a ShellScreen back to Hyprland.
Singleton {
    id: root

    readonly property string name: Hyprland.focusedMonitor ? Hyprland.focusedMonitor.name : ""

    // True when `screen` is the one a panel opened on. `capturedName` is the
    // name recorded at open time, so the panel stays put if focus moves away
    // while it's open. An empty capture means "we couldn't tell" — fall back to
    // the primary screen so the panel is never invisible on every monitor.
    function matches(screen, capturedName) {
        if (!screen)
            return false;

        if (capturedName) {
            const monitor = Hyprland.monitorFor(screen);
            return monitor ? monitor.name === capturedName : false;
        }

        return Quickshell.screens.length > 0 && screen === Quickshell.screens[0];
    }
}
