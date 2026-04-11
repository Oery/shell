//@ pragma UseQApplication
//@ pragma IconTheme YAMIS

import QtQuick
import Quickshell
import Quickshell.Io
import qs.panels
import qs.statusbar
import qs.desktop
import qs.system
import qs.utils

Scope {
    property var _appLauncher: AppLauncher
    property var _desktopEntries: DesktopEntries

    Bar {}
    Wallpaper {}

    IpcHandler {
        target: "leftpanel"

        function toggle(): void {
            SidePanel.toggle();
        }
    }

    IpcHandler {
        target: "launcher"

        function toggle(): void {
            AppLauncher.toggle();
        }
    }

    IpcHandler {
        target: "rightpanel"

        function toggle(): void {
            print("Toggle right panel");
            RightPanel.toggle();
        }
    }

    IpcHandler {
        target: "wallpaper"

        function toggle(): void {
            Config.wallpaperSelectorVisible = !Config.wallpaperSelectorVisible;
        }
    }
}
