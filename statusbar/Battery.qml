import Quickshell.Services.UPower
import QtQuick

Text {
    visible: UPower.displayDevice.isLaptopBattery
    text: getBatteryText()
    color: '#F7F1FF'
    font.family: "JetBrains Mono"
    textFormat: Text.RichText

    function getBatteryText() {
        var pct = Math.round(UPower.displayDevice.percentage * 100);
        var charging = UPower.displayDevice.state == UPowerDeviceState.Charging;
        var full = UPower.displayDevice.state == UPowerDeviceState.FullyCharged;
        var dot = "";
        if (full)
            dot = "<span style='color:#4CAF50'>\u25CF</span>";
        else if (pct < 10)
            dot = "<span style='color:#F44336'>\u25CF</span>";
        else if (pct < 20)
            dot = "<span style='color:#FF9800'>\u25CF</span>";
        return pct + "% " + UPower.displayDevice.changeRate.toFixed(2) + "W " + dot + " | ";
    }
}
