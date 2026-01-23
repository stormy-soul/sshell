pragma Singleton
import QtQuick
import Quickshell

QtObject {
    id: root
    
    // Base directories using QuickShell.shellPath for absolute paths
    readonly property string projectRoot: Quickshell.env("PWD") || Quickshell.env("HOME") + "/Documents/Projects/sshell"
    readonly property string assetsPath: Quickshell.shellPath("assets")
    readonly property string iconsPath: assetsPath + "/material-design-icons/svg"
    
    // System directories
    readonly property string home: Quickshell.env("HOME")
    readonly property string configHome: Quickshell.env("XDG_CONFIG_HOME") || (home + "/.config")
    readonly property string dataHome: Quickshell.env("XDG_DATA_HOME") || (home + "/.local/share")
    readonly property string cacheHome: Quickshell.env("XDG_CACHE_HOME") || (home + "/.cache")
    
    // Application directories
    readonly property var appDirs: [
        "/usr/share/applications",
        dataHome + "/applications"
    ]
    
    // Icon directories (system icons, in priority order)
    readonly property var systemIconDirs: [
        "/usr/share/icons/hicolor/scalable/apps/",
        "/usr/share/icons/hicolor/256x256/apps/",
        "/usr/share/icons/hicolor/128x128/apps/",
        "/usr/share/icons/hicolor/48x48/apps/",
        "/usr/share/pixmaps/"
    ]
    
    // Helper function to get Material Design icon path (filesystem path, no file://)
    function getMaterialIcon(iconName, iconType) {
        return iconsPath + "/" + iconType + "/" + iconName + ".svg"
    }
    
    // Helper function to get full file:// URL for Material Design icon
    function getMaterialIconUrl(iconName, iconType) {
        return "file://" + getMaterialIcon(iconName, iconType)
    }
    
    Component.onCompleted: {
        console.log("Directories: Assets path:", assetsPath)
        console.log("Directories: Icons path:", iconsPath)
    }
}
