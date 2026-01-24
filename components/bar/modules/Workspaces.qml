import QtQuick
import Quickshell.Hyprland
import "../../../settings"
import "../../../services"

Row {
    id: workspaces
    spacing: Appearance.sizes.padding

    function getSortedWorkspaceIds() {
        var _trigger = Hyprland.workspaces.length 
        let ids = new Set(Config.workspaces.persistent)
        
        for (let i = 0; i < Hyprland.workspaces.length; i++) {
            ids.add(Hyprland.workspaces[i].id)
        }
        
        return Array.from(ids).sort((a, b) => a - b)
    }

    function getHyprlandWorkspace(id) {
        var _trigger = Hyprland.workspaces.length
        for (let i = 0; i < Hyprland.workspaces.length; i++) {
            if (Hyprland.workspaces[i].id === id) return Hyprland.workspaces[i]
        }
        return null
    }
    
    Repeater {
        model: workspaces.getSortedWorkspaceIds()
        
        Rectangle {
            id: wsRect
            readonly property int wsId: modelData
            property var activeWsObject: workspaces.getHyprlandWorkspace(wsId)

            height: (Config.bar.height || 40) - (workspaces.spacing * 2)
            width: height
            radius: Appearance.sizes.cornerRadiusSmall
            
            property bool isFocused: Hyprland.focusedWorkspace && Hyprland.focusedWorkspace.id === wsId
            property bool hasWindows: activeWsObject ? (activeWsObject.clients.length > 0) : false
            property bool existsInHyprland: activeWsObject !== null             
    
            color: {
                if (isFocused) return Appearance.colors.accent
                if (hasWindows) return Appearance.colors.surface
                if (existsInHyprland) return Appearance.colors.surface
                return "transparent" 
            }
            
            Behavior on color {
                ColorAnimation { duration: Appearance.animation.duration }
            }
            
            Text {
                anchors.centerIn: parent
                text: wsRect.wsId
                font.family: Appearance.font.family.main
                font.pixelSize: Appearance.font.pixelSize.normal
                font.weight: wsRect.isFocused ? Font.DemiBold : Font.Normal
                color: wsRect.isFocused ? (Colors.isDark(wsRect.color) ? Appearance.colors.text : Appearance.colors.colOnPrimary) : Appearance.colors.text
            }
            
            MouseArea {
                anchors.fill: parent
                onClicked: {
                    Hyprland.dispatch("workspace " + wsRect.wsId)
                }
            }
        }
    }
}