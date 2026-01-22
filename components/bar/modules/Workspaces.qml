import QtQuick
import Quickshell.Hyprland

import "../../../services"
import "../../../theme"

Row {
    id: workspaces
    spacing: Theme.padding

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
            radius: Theme.cornerRadiusSmall
            
            property bool isFocused: Hyprland.focusedWorkspace && Hyprland.focusedWorkspace.id === wsId
            property bool hasWindows: activeWsObject ? (activeWsObject.clients.length > 0) : false
            property bool existsInHyprland: activeWsObject !== null             
    
            color: {
                if (isFocused) return Theme.accent || "#a6e3a1"
                if (hasWindows) return Theme.surface || "#313244"
                if (existsInHyprland) return Theme.surface || "#313244"
                return "transparent" 
            }
            
            Behavior on color {
                ColorAnimation { duration: Theme.animationDuration }
            }
            
            Text {
                anchors.centerIn: parent
                text: wsRect.wsId
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSize
                font.weight: wsRect.isFocused ? Font.DemiBold : Font.Normal
                color: wsRect.isFocused ? Theme.background : Theme.text
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