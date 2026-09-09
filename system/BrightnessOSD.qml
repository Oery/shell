import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland

Scope {
	id: root

	property real brightness: 0
	property bool shouldShowOsd: false
	property bool readPending: false

	IpcHandler {
		target: "brightness"

		function display(): void {
			root.shouldShowOsd = true;
			hideTimer.restart();

			if (brightnessRead.running) {
				root.readPending = true;
			} else {
				brightnessRead.running = true;
			}
		}
	}

	Process {
		id: brightnessRead
		command: ["brightnessctl", "-m"]

		stdout: StdioCollector {
			onStreamFinished: {
				const fields = this.text.trim().split("\n")[0].split(",");
				if (fields.length < 5)
					return;

				const current = parseInt(fields[2]);
				const maximum = parseInt(fields[4]);
				if (!isFinite(current) || !isFinite(maximum) || maximum <= 0)
					return;

				const newBrightness = Math.max(0, Math.min(1, current / maximum));
				root.brightness = newBrightness;
			}
		}

		onExited: {
			if (root.readPending) {
				root.readPending = false;
				brightnessRead.running = true;
			}
		}
	}

	// Seed the displayed value once at startup. Further reads only happen after
	// an explicit IPC event from a brightness control.
	Component.onCompleted: brightnessRead.running = true

	Timer {
		id: hideTimer
		interval: 1000
		onTriggered: root.shouldShowOsd = false
	}

	LazyLoader {
		active: root.shouldShowOsd

		PanelWindow {
			WlrLayershell.namespace: "quickshell-osd"

			anchors.bottom: true
			margins.bottom: screen.height / 10
			exclusiveZone: 0

			implicitWidth: 400
			implicitHeight: 50
			color: "transparent"
			mask: Region {}

			Rectangle {
				anchors.fill: parent
				radius: height / 2
				color: "#d8080808"

				RowLayout {
					anchors {
						fill: parent
						leftMargin: 10
						rightMargin: 15
					}

					Text {
						text: "󰃠"
						font.pixelSize: 24
						color: "white"
						Layout.preferredWidth: 30
						horizontalAlignment: Text.AlignHCenter
						verticalAlignment: Text.AlignVCenter
					}

					Rectangle {
						Layout.fillWidth: true
						implicitHeight: 10
						radius: 20
						color: "#50ffffff"

						Rectangle {
							anchors {
								left: parent.left
								top: parent.top
								bottom: parent.bottom
							}
							implicitWidth: parent.width * root.brightness
							radius: parent.radius
						}
					}
				}
			}
		}
	}
}
