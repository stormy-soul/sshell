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
    
    // Derived property for icon path
    property string osIconPath: {
        var base = Quickshell.shellPath("assets/icons/")
        var icon = base + osName + "-symbolic.svg"

        return icon
    }
    
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
                } catch (e) {
                    console.warn("SystemInfo: Failed to parse:", data)
                }
            }
        }
    }
    
    Component.onCompleted: proc.running = true
}
