import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Hyprland

Scope {
    id: root
    
    property bool isVisible: false
    property var tailscale // Tailscale instance passed from Bar
    
    Variants {
        model: Quickshell.screens
        
        PanelWindow {
            id: sidePanel
            required property var modelData
            
            screen: modelData
            visible: root.isVisible
            
            anchors {
                top: true
                left: true
                bottom: true
            }
            
            implicitWidth: 400
            color: 'transparent'

            exclusiveZone: 0
            focusable: true
            
            Rectangle {
                color: '#f2080808'
                anchors.fill: parent
                anchors.margins: 5
                radius: 4
                
                focus: true
                Keys.enabled: true
                Keys.onPressed: event => {
                    if (event.key === Qt.Key_Escape) {
                        root.isVisible = false;
                        event.accepted = true;
                    }
                }
                
                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 10
                    spacing: 10
                    
                    StyledText { 
                        text: "Panel"
                        font.pixelSize: 14
                        font.bold: true
                    }
                    
                    Rectangle {
                        Layout.fillWidth: true
                        height: 1
                        color: '#40FFFFFF'
                    }
                    
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 8
                        
                        StyledText { 
                            text: "Quick Access"
                            font.pixelSize: 12
                        }
                        
                        Rectangle {
                            Layout.fillWidth: true
                            height: 30
                            color: "transparent"
                            radius: 4
                            
                            Text {
                                anchors.left: parent.left
                                anchors.verticalCenter: parent.verticalCenter
                                anchors.leftMargin: 8
                                text: "Terminal"
                                color: '#F7F1FF'
                                font.family: "JetBrains Mono"
                                font.pixelSize: 11
                            }
                            
                            MouseArea {
                                anchors.fill: parent
                                hoverEnabled: true
                                
                                onEntered: parent.color = '#20FFFFFF'
                                onExited: parent.color = "transparent"
                                onPressed: parent.color = '#40FFFFFF'
                                onReleased: parent.color = containsMouse ? '#20FFFFFF' : "transparent"
                            }
                        }
                        
                        Rectangle {
                            Layout.fillWidth: true
                            height: 30
                            color: "transparent"
                            radius: 4
                            
                            Text {
                                anchors.left: parent.left
                                anchors.verticalCenter: parent.verticalCenter
                                anchors.leftMargin: 8
                                text: "File Manager"
                                color: '#F7F1FF'
                                font.family: "JetBrains Mono"
                                font.pixelSize: 11
                            }
                            
                            MouseArea {
                                anchors.fill: parent
                                hoverEnabled: true
                                
                                onEntered: parent.color = '#20FFFFFF'
                                onExited: parent.color = "transparent"
                                onPressed: parent.color = '#40FFFFFF'
                                onReleased: parent.color = containsMouse ? '#20FFFFFF' : "transparent"
                            }
                        }
                        
                        Rectangle {
                            Layout.fillWidth: true
                            height: 30
                            color: "transparent"
                            radius: 4
                            
                            Text {
                                anchors.left: parent.left
                                anchors.verticalCenter: parent.verticalCenter
                                anchors.leftMargin: 8
                                text: "Settings"
                                color: '#F7F1FF'
                                font.family: "JetBrains Mono"
                                font.pixelSize: 11
                            }
                            
                            MouseArea {
                                anchors.fill: parent
                                hoverEnabled: true
                                
                                onEntered: parent.color = '#20FFFFFF'
                                onExited: parent.color = "transparent"
                                onPressed: parent.color = '#40FFFFFF'
                                onReleased: parent.color = containsMouse ? '#20FFFFFF' : "transparent"
                            }
                        }
                    }
                    
                    Rectangle {
                        Layout.fillWidth: true
                        height: 1
                        color: '#40FFFFFF'
                    }
                    
                    // Tailscale Status Section
                    ColumnLayout {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        spacing: 8
                        
                        RowLayout {
                            Layout.fillWidth: true
                            
                            StyledText { 
                                text: "Tailscale"
                                font.pixelSize: 12
                            }
                            
                            Item { Layout.fillWidth: true }
                            
                            Rectangle {
                                width: 12
                                height: 12
                                radius: 6
                                color: tailscale && tailscale.isConnected ? '#4CAF50' : '#F44336'
                                
                                Behavior on color {
                                    ColorAnimation { duration: 300 }
                                }
                            }
                        }
                        
                        // Connection Status
                        StyledText {
                            text: tailscale && tailscale.isConnected ? "Connected" : "Disconnected"
                            font.pixelSize: 10
                            color: tailscale && tailscale.isConnected ? '#4CAF50' : '#F44336'
                            visible: tailscale && tailscale.status !== "Unknown"
                        }
                        
                        // Peers List
                        ScrollView {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            Layout.preferredHeight: 200
                            
                            visible: tailscale && tailscale.peers.length > 0
                            
                            ColumnLayout {
                                width: parent.width
                                spacing: 4
                                
                                Repeater {
                                    model: tailscale ? tailscale.peers : []
                                    
                                    delegate: Rectangle {
                                        Layout.fillWidth: true
                                        height: 60
                                        color: "transparent"
                                        radius: 4
                                        border.color: modelData && modelData.online === true ? '#4CAF50' : '#808080'
                                        border.width: 1
                                        
                                        RowLayout {
                                            anchors.fill: parent
                                            anchors.margins: 8
                                            spacing: 8
                                            
                                            // Online Status Indicator
                                            Rectangle {
                                                width: 8
                                                height: 8
                                                radius: 4
                                                color: modelData && modelData.online ? '#4CAF50' : '#808080'
                                            }
                                            
                                            ColumnLayout {
                                                Layout.fillWidth: true
                                                spacing: 2
                                                
                                                StyledText {
                                                    text: modelData.name || modelData.id
                                                    font.pixelSize: 11
                                                    font.bold: true
                                                    Layout.fillWidth: true
                                                    elide: Text.ElideRight
                                                }
                                                
                                                StyledText {
                                                    text: modelData.dnsName || modelData.id
                                                    font.pixelSize: 9
                                                    color: '#AAAAAA'
                                                    Layout.fillWidth: true
                                                    elide: Text.ElideRight
                                                }
                                                
                                                Row {
                                                    spacing: 8
                                                    
                                                    StyledText {
                                                        text: modelData.online === true ? "Online" : "Offline"
                                                        font.pixelSize: 9
                                                        color: modelData && modelData.online === true ? '#4CAF50' : '#808080'
                                                    }
                                                    
                                                    // Latency Display
                                                    StyledText {
                                                        visible: modelData.online === true
                                                        text: modelData.measuringLatency ? "Ping..." : 
                                                               (modelData.latency ? (modelData.latency.toFixed(1) + "ms") : "---")
                                                        font.pixelSize: 9
                                                        color: modelData.latency ? 
                                                               (modelData.latency < 50 ? '#4CAF50' : 
                                                                (modelData.latency < 100 ? '#FFC107' : '#F44336')) : '#AAAAAA'
                                                    }
                                                }
                                            }
                                        }
                                        
                                        MouseArea {
                                            anchors.fill: parent
                                            hoverEnabled: true
                                            
                                            onEntered: parent.color = '#20FFFFFF'
                                            onExited: parent.color = "transparent"
                                        }
                                    }
                                }
                            }
                        }
                        
                        // No Peers Message
                        StyledText {
                            text: {
                                if (!tailscale) return "Loading..."
                                return tailscale.isConnected ? "No peers found" : "Connect to see peers"
                            }
                            font.pixelSize: 10
                            color: '#AAAAAA'
                            horizontalAlignment: Text.AlignHCenter
                            Layout.fillWidth: true
                            visible: !tailscale || tailscale.peers.length === 0
                        }
                        
                        // Control Buttons
                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 8
                            
                            Rectangle {
                                Layout.fillWidth: true
                                height: 30
                                color: tailscale && tailscale.isConnected ? '#F44336' : '#4CAF50'
                                radius: 4
                                
                                Text {
                                    anchors.centerIn: parent
                                    text: tailscale && tailscale.isConnected ? "Disconnect" : "Connect"
                                    color: 'white'
                                    font.family: "JetBrains Mono"
                                    font.pixelSize: 11
                                }
                                
                                MouseArea {
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    
                                    property bool isConnected: tailscale && tailscale.isConnected === true
                                    
                                    onEntered: parent.color = isConnected ? '#D32F2F' : '#388E3C'
                                    onExited: parent.color = isConnected ? '#F44336' : '#4CAF50'
                                    onPressed: parent.color = isConnected ? '#B71C1C' : '#2E7D32'
                                    onReleased: {
                                        if (containsMouse) {
                                            parent.color = isConnected ? '#F44336' : '#4CAF50'
                                        }
                                    }
                                    onClicked: {
                                        if (tailscale) {
                                            if (tailscale.isConnected) {
                                                tailscale.disconnect();
                                            } else {
                                                tailscale.connect();
                                            }
                                        }
                                    }
                                }
                                
                                MouseArea {
                                    anchors.fill: parent
                                    hoverEnabled: true && !(tailscale && tailscale.measuringLatency)
                                    
                                    onEntered: if (!tailscale || !tailscale.measuringLatency) parent.color = '#F57C00'
                                    onExited: if (!tailscale || !tailscale.measuringLatency) parent.color = '#FF9800'
                                    onPressed: if (!tailscale || !tailscale.measuringLatency) parent.color = '#E65100'
                                    onReleased: {
                                        if (containsMouse && (!tailscale || !tailscale.measuringLatency)) {
                                            parent.color = '#FF9800'
                                        }
                                    }
                                    onClicked: {
                                        if (tailscale && !tailscale.measuringLatency) {
                                            console.log("Ping All button clicked");
                                            console.log("tailscale:", tailscale);
                                            console.log("measuringLatency:", tailscale.measuringLatency);
                                            console.log("Calling measureAllLatency");
                                            tailscale.measureAllLatency();
                                        } else {
                                            console.log("Not calling measureAllLatency - measuring in progress or tailscale not available");
                                        }
                                    }
                                }
                            }
                            
                            Rectangle {
                                Layout.preferredWidth: 70
                                height: 30
                                color: '#2196F3'
                                radius: 4
                                
                                Text {
                                    anchors.centerIn: parent
                                    text: "Refresh"
                                    color: 'white'
                                    font.family: "JetBrains Mono"
                                    font.pixelSize: 11
                                }
                                
                                MouseArea {
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    
                                    onEntered: parent.color = '#1976D2'
                                    onExited: parent.color = '#2196F3'
                                    onPressed: parent.color = '#0D47A1'
                                    onReleased: {
                                        if (containsMouse) {
                                            parent.color = '#2196F3'
                                        }
                                    }
                                    onClicked: if (tailscale) tailscale.refresh()
                                }
                            }
                            
                            Rectangle {
                                Layout.preferredWidth: 70
                                height: 30
                                color: (tailscale && tailscale.measuringLatency) ? '#CCCCCC' : '#FF9800'
                                radius: 4
                                
                                Text {
                                    anchors.centerIn: parent
                                    text: (tailscale && tailscale.measuringLatency) ? "Pinging..." : "Ping All"
                                    color: (tailscale && tailscale.measuringLatency) ? '#666666' : 'white'
                                    font.family: "JetBrains Mono"
                                    font.pixelSize: 11
                                }
                                
                                MouseArea {
                                    anchors.fill: parent
                                    hoverEnabled: true && !(tailscale && tailscale.measuringLatency)
                                    
                                    onEntered: if (!tailscale || !tailscale.measuringLatency) parent.color = '#F57C00'
                                    onExited: if (!tailscale || !tailscale.measuringLatency) parent.color = '#FF9800'
                                    onPressed: if (!tailscale || !tailscale.measuringLatency) parent.color = '#E65100'
                                    onReleased: {
                                        if (containsMouse && (!tailscale || !tailscale.measuringLatency)) {
                                            parent.color = '#FF9800'
                                        }
                                    }
                                    onClicked: {
                                        if (tailscale && !tailscale.measuringLatency) {
                                            console.log("Ping All button clicked");
                                            console.log("tailscale:", tailscale);
                                            console.log("measuringLatency:", tailscale.measuringLatency);
                                            console.log("Calling measureAllLatency");
                                            tailscale.measureAllLatency();
                                        } else {
                                            console.log("Not calling measureAllLatency - measuring in progress or tailscale not available");
                                        }
                                    }
                                }
                            }
                        }
                    }
                    
                    Item { Layout.fillHeight: true }
                }
            }

            
        }
    }

    function toggle() {
        isVisible = !isVisible;
    }
}
