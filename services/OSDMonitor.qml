pragma Singleton
import QtQuick
import Quickshell
import "."

Singleton {
    id: root

    property bool ready: false
    Timer {
        interval: 2000
        running: true
        onTriggered: root.ready = true
    }

    // Audio Monitoring
    Timer {
        id: audioDebounce
        interval: 50 // Slightly increased debounce
        repeat: false
        onTriggered: {
             if (!root.ready) return
             
             var vol = Math.round(Audio.volume * 100)
             var icon = Audio.muted ? "volume_off" : 
                        (vol > 50 ? "volume_up" : (vol > 0 ? "volume_down" : "volume_mute"))
             
             OSD.show(icon, vol, "Volume", vol + "%")
        }
    }

    Connections {
        target: Audio
        function onVolumeChanged() { audioDebounce.restart() }
        function onMutedChanged() { audioDebounce.restart() }
    }
    
    // Brightness Monitoring
    Timer {
        id: brightnessDebounce
        interval: 50
        repeat: false
        onTriggered: {
            if (!root.ready) return
            var val = Math.round(Brightness.brightness * 100)
            OSD.show("brightness_medium", val, "Brightness", val + "%")
        }
    }
    
    Connections {
        target: Brightness
        function onBrightnessChanged() { brightnessDebounce.restart() }
    }
    
    function showBrightnessOSD() {
        brightnessDebounce.restart()
    }
}
