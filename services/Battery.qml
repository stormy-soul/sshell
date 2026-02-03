pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    property real percentage: 0
    property bool isCharging: false
    property bool isPluggedIn: isCharging 
    
    property int timeToFull: 0      // seconds
    property int timeToEmpty: 0     // seconds
    property real energyRate: 0     // watts
    property real health: 100       // percentage
    property int chargeState: 0     // 1=charging, 2=discharging, 4=full
    
    Process {
        id: proc
        command: [Quickshell.shellPath("services/helpers/get_battery.sh")]
        
        stdout: SplitParser {
            onRead: data => {
                try {
                    var json = JSON.parse(data.trim())
                    root.percentage = json.percentage / 100.0
                    root.isCharging = json.state === "Charging"
                    root.timeToFull = json.time_to_full || 0
                    root.timeToEmpty = json.time_to_empty || 0
                    root.energyRate = json.energy_rate || 0
                    root.health = json.health || 100
                    root.chargeState = json.charge_state || 0
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
