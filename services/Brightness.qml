pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    property real brightness: 0.5
    
    Process {
        id: maxProc
        command: ["brightnessctl", "m"]
        running: true
        stdout: SplitParser {
            onRead: data => {
                root._max = parseInt(data.trim()) || 255
                console.log("BrightnessService: Max brightness detected as", root._max)
            }
        }
    }
    
    Process {
        id: getProc
        command: ["brightnessctl", "g"]
        running: true
        stdout: SplitParser {
            onRead: data => {
                var current = parseInt(data.trim()) || 0
                if (root._max > 0) root.brightness = current / root._max
            }
        }
    }
    
    property int _max: 255
    
    function setBrightness(val) {
        if (val < 0) val = 0
        if (val > 1) val = 1
        root.brightness = val
        var actual = Math.round(val * root._max)
        if (actual < 1) actual = 1
        Quickshell.execDetached(["brightnessctl", "s", actual.toString()])
    }
    
    function change(delta) {
        setBrightness(root.brightness + delta)
    }

    function refresh() {
        getProc.running = false
        getProc.running = true
    }
}
