import Quickshell
import Quickshell.Hyprland

StyledText {
	text: {
		let title = Hyprland?.activeToplevel?.title ?? "";
		title = title.replace(' — Zen Browser', '');
		title = title.length > 55 ? title.substring(0, 55) + "..." : title
		return "| " + title;
	}
}
