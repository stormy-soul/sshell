pragma Singleton
import QtQuick
import Quickshell.Hyprland

QtObject {
    readonly property var instance: Hyprland
    
    readonly property var workspaces: Hyprland.workspaces
    readonly property var activeWindow: Hyprland.focusedMonitor.activeWindow
}