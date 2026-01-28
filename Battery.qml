import Quickshell
import Quickshell.Services.UPower

StyledText {
	visible: UPower.displayDevice.isLaptopBattery
	text: "" + Math.round(UPower.displayDevice.percentage * 100) + "% " + UPower.displayDevice.changeRate.toFixed(2) + "W |";
}
