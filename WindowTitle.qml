import Quickshell
import Quickshell.Hyprland

StyledText {
	text: {
		let title = Hyprland.activeToplevel.title;
		title = title.replace(' — Zen Browser', '');
		return "| " + title;
	}
}
