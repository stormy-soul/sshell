pragma Singleton
import QtQuick
import Quickshell

Singleton {
    id: root

    property bool masterVisible: true

    function toggle() {
        root.masterVisible = !root.masterVisible
    }
    
    function show() {
        root.masterVisible = true
    }
    
    function hide() {
        root.masterVisible = false
    }
}
