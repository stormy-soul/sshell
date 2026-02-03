pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root
    
    property var values: [0, 0, 0, 0, 0, 0]
    property bool running: false
    property bool available: false
    
    readonly property string configPath: Qt.resolvedUrl("helpers/cava_config").toString().replace("file://", "")
    
    Component.onCompleted: {
        if (MprisController.isPlaying) {
            root.start()
        }
    }
    
    Process {
        id: checkCava
        command: ["which", "cava"]
        running: true
        onExited: (code) => {
            root.available = (code === 0)
            if (root.available) {
                if (MprisController.isPlaying) {
                    root.running = true
                }
            } else {
                console.warn("[CavaService] CAVA not installed. Visualizer will be disabled.")
            }
        }
    }
    
    Process {
        id: cavaProcess
        command: ["cava", "-p", root.configPath]
        running: root.running && root.available
        
        stdout: SplitParser {
            onRead: (line) => {
                root.parseLine(line)
            }
        }
        
        onExited: (code) => {
            if (root.running) {
                restartTimer.start()
            }
        }
    }
    
    Timer {
        id: restartTimer
        interval: 1000
        onTriggered: {
            if (root.running && root.available) {
                cavaProcess.running = true
            }
        }
    }
    
    function parseLine(line) {
        var parts = line.trim().split(";")
        if (parts.length >= 6) {
            var newValues = []
            for (var i = 0; i < 6; i++) {
                var val = parseInt(parts[i]) || 0
                newValues.push(val / 255.0)
            }
            root.values = newValues
        }
    }
    
    function start() {
        if (root.available) {
            root.running = true
        }
    }
    
    function stop() {
        root.running = false
        root.values = [0, 0, 0, 0, 0, 0]
    }
    
    Connections {
        target: MprisController
        
        function onIsPlayingChanged() {
            if (MprisController.isPlaying) {
                root.start()
            } else {
                root.stop()
            }
        }
    }
}
