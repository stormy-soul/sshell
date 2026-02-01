pragma Singleton
import QtQuick

QtObject {
    id: root

    property bool launcherVisible: false
    property bool clipboardMode: false

    function toggleLauncher() {
        launcherVisible = !launcherVisible
        if (!launcherVisible) clipboardMode = false
    }
    
    function toggleClipboard() {
        clipboardMode = true
        launcherVisible = !launcherVisible
        if (!launcherVisible) clipboardMode = false
    }

    property bool controlCenterVisible: false
    function toggleControlCenter() {
        controlCenterVisible = !controlCenterVisible
    }

}


