pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    property real percentage: 0
    property bool isCharging: false
    property bool isPluggedIn: isCharging 
    
    Process {
        id: proc
        command: [Quickshell.shellPath("services/helpers/get_battery.sh")]
        //autoStarted: false
        
        stdout: SplitParser {
            onRead: data => {
                try {
                    var json = JSON.parse(data.trim())
                    root.percentage = json.percentage / 100.0
                    root.isCharging = json.state === "Charging"
                } catch (e) {
                    console.warn("Battery: Failed to parse:", data)
                }
            }
        }
    }
    
    Timer {
        interval: 5000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: proc.running = true
    }
}
