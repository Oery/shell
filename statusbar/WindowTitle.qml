import Quickshell.Hyprland
import qs.utils

StyledText {
    text: {
        let title = Hyprland?.activeToplevel?.title ?? "";
        title = title.replace(' — Zen Browser', '');
        title = title.length > 61 ? title.substring(0, 58) + "..." : title;
        return " | " + title;
    }
}
