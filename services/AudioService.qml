pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    property real volume: 0.5
    property bool muted: false
    
    Process {
        id: statusProc
        command: ["bash", "-c", "wpctl get-volume @DEFAULT_AUDIO_SINK@"]
        stdout: SplitParser {
            onRead: data => {
                var parts = data.split(" ")
                // parts[1] is usually volume
                if (parts.length > 1) {
                    root.volume = parseFloat(parts[1]) || 0
                }
                if (data.includes("MUTED")) {
                    root.muted = true
                } else {
                    root.muted = false
                }
            }
        }
    }
    
    Timer {
        interval: 2000
        running: true
        repeat: true
        onTriggered: statusProc.running = true
    }
    
    property real pendingVolume: -1
    
    Timer {
         id: volumeTimer
         interval: 50
         repeat: false
         onTriggered: {
             if (root.pendingVolume >= 0) {
                 Quickshell.execDetached(["wpctl", "set-volume", "@DEFAULT_AUDIO_SINK@", root.pendingVolume.toString()])
                 root.pendingVolume = -1
             }
         }
    }

    function setVolume(val) {
        if (val < 0) val = 0
        if (val > 1.5) val = 1.5
        root.volume = val
        root.pendingVolume = val
        if (!volumeTimer.running) volumeTimer.start()
    }
    
    function toggleMute() {
        Quickshell.execDetached(["wpctl", "set-mute", "@DEFAULT_AUDIO_SINK@", "toggle"])
        root.muted = !root.muted
    }

    function refresh() {
        statusProc.running = false
        statusProc.running = true
    }
}
