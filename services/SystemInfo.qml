pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    property string osName: "linux"
    property string userName: "user"
    property string hostName: "host"
    property string profilePicture: ""
    property string chassis: "laptop"
    property string uptime: "--:--"
    
    property string osIconPath: {
        var base = Quickshell.shellPath("assets/icons/")
        var icon = base + osName + "-symbolic.svg"
        return icon
    }
    
    property bool isLaptop: chassis === "laptop" || chassis === "notebook" || chassis === "convertible"
    property bool isDesktop: chassis === "desktop" || chassis === "server" || chassis === "vm"
    
    Process {
        id: proc
        command: [Quickshell.shellPath("services/helpers/get_sysinfo.sh")]
        
        stdout: SplitParser {
            onRead: data => {
                try {
                    var json = JSON.parse(data.trim())
                    root.osName = json.os || "linux"
                    root.userName = json.user || "user"
                    root.hostName = json.host || "host"
                    root.profilePicture = json.pfp || ""
                    root.chassis = json.chassis || "laptop"
                } catch (e) {
                    console.warn("SystemInfo: Failed to parse:", data)
                }
            }
        }
    }
    
    property string uptimeBuffer: ""
    Process {
        id: uptimeProc
        command: ["cat", "/proc/uptime"]
        
        stdout: SplitParser {
            onRead: data => {
                root.uptimeBuffer = data
            }
        }
        
        onExited: {
            try {
                var seconds = parseFloat(root.uptimeBuffer.split(" ")[0])
                var hours = Math.floor(seconds / 3600)
                var mins = Math.floor((seconds % 3600) / 60)
                root.uptime = hours + "h " + mins + "m"
            } catch (e) {
                root.uptime = "--:--"
            }
            root.uptimeBuffer = ""
        }
    }
    
    Timer {
        interval: 60000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: uptimeProc.running = true
    }
    
    Component.onCompleted: proc.running = true
}
