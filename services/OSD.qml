pragma Singleton
import QtQuick
import Quickshell
import "../settings"

Scope {
    id: root
    
    property bool visible: false
    property string icon: ""
    property real value: -1 
    property string text: ""
    property string label: "" 
    
    property Timer hideTimer: Timer {
        interval: Config.osd?.timeout ?? 1500
        onTriggered: root.visible = false
    }
    
    function show(iconName, val, labelText, msg) {
        root.icon = iconName || ""
        root.value = (val !== undefined && val !== null) ? val : -1
        root.label = labelText || ""
        root.text = msg || ""
        root.visible = true
        hideTimer.restart()
    }
    
    function hide() {
        root.visible = false
        hideTimer.stop()
    }
    
    Component.onCompleted: {
        Qt.callLater(function() {
            show("check_circle", null, "", "Loaded")
        })
    }
}
