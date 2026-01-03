import Quickshell
import Quickshell.Services.UPower

StyledText {
	text: "" + Math.round(UPower.displayDevice.percentage * 100) + "% " + UPower.displayDevice.changeRate.toFixed(2) + "W |";
}
