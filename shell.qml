import Quickshell
import Quickshell.Io

ShellRoot {
    id: root

    Process {
        id: configLoader
        command: ["cat", Quickshell.env("HOME") + "/Documents/Projects/sshell/config.jsonc"]
        running: true

        onExited: {
            
        }
    }
}