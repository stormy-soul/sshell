pragma Singleton
import QtQuick

QtObject {
    id: root

    property bool launcherVisible: false

    function toggleLauncher() {
        launcherVisible = !launcherVisible
    }

}
