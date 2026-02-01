pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root
    
    property bool wifiEnabled: false
    property string wifiStatus: "disconnected"
    property string ssid: ""
    property int signalStrength: 0

    property bool ethernetConnected: false
    property string ethernetDevice: ""

    
    function update() {
        detailsProc.running = true
    }
    
    Timer {
        interval: 5000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: root.update()
    }
    
    Process {
        id: detailsProc
        
        command: ["bash", "-c", "nmcli -t -f TYPE,DEVICE,STATE,CONNECTION device | grep '^ethernet.*connected' | head -1; nmcli -t -f ACTIVE,SSID,SIGNAL dev wifi | grep '^yes' | head -1"]
        
        stdout: SplitParser {
            onRead: data => {
                var lines = data.split("\n")
                root.ethernetConnected = false
                
                for (var i=0; i<lines.length; i++) {
                    var line = lines[i]
                    if (!line) continue
                    
                    if (line.startsWith("ethernet")) {
                         var parts = line.split(":")
                         if (parts[2] === "connected") {
                             root.ethernetConnected = true
                             root.ethernetDevice = parts[1]
                         }
                    } else {
                         var parts = line.split(":")
                         if (parts.length >= 3 && parts[0] === "yes") {
                            root.wifiStatus = "connected"
                            root.ssid = parts[1]
                            root.signalStrength = parseInt(parts[2]) || 0
                         }
                    }
                }
            }
        }
        
        onExited: (exitCode, exitStatus) => {
           if (exitCode !== 0 || root.ssid === "") {
               checkRadio.running = true
           } else {
               root.wifiEnabled = true
           }
        }
    }
    
    Process {
        id: checkRadio
        command: ["nmcli", "radio", "wifi"]
        stdout: SplitParser {
            onRead: data => {
                if (data.trim() === "enabled") {
                    root.wifiEnabled = true
                    if (root.wifiStatus === "connected") return 
                    root.wifiStatus = "disconnected"
                    root.ssid = ""
                    root.signalStrength = 0
                } else {
                    root.wifiEnabled = false
                    root.wifiStatus = "off"
                    root.ssid = ""
                    root.signalStrength = 0
                }
            }
        }
    }
    function toggleWifi() {
        var cmd = root.wifiEnabled ? "off" : "on"
        toggleProc.command = ["nmcli", "radio", "wifi", cmd]
        toggleProc.running = true
        // Optimistic update?
        // root.wifiEnabled = !root.wifiEnabled 
        // Better wait for checkRadio
    }
    
    Process {
        id: toggleProc
        onExited: checkRadio.running = true
    }
}
