import QtQuick
import Quickshell.Hyprland
import "../../../settings"
import "../../../services"

Row {
    id: workspaces
    spacing: 0

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

    function getWorkspaceLabel(id) {
        var style = Config.configAdapter.workspaces.style || "arabic" 
        style = Config.workspaces.style || "arabic"
        
        if (style === "arabic") return id.toString()
        
        if (style === "roman") {
            var romals = ["", "I", "II", "III", "IV", "V", "VI", "VII", "VIII", "IX", "X"]
            if (id > 0 && id <= 10) return romals[id]
            return id.toString()
        }
        
        if (style === "han") {
            var hans = ["", "一", "二", "三", "四", "五", "六", "七", "八", "九", "十"]
            if (id > 0 && id <= 10) return hans[id]
            return id.toString()
        }
        
        if (style === "dot") {
            return "●" // or "•"
        }
        
        return id.toString()
    }
    
    function checkOccupied(id) {
        var params = Hyprland.workspaces.values
        for (let i = 0; i < params.length; i++) {
             if (params[i].id === id) return params[i].clients.length > 0
        }
        return false
    }

    function checkFocused(id) {
        return Hyprland.focusedWorkspace && Hyprland.focusedWorkspace.id === id
    }

    Repeater {
        id: repeater
        model: workspaces.getSortedWorkspaceIds()
        
        Item {
            id: delegate
            readonly property int wsId: modelData
            property var activeWsObject: workspaces.getHyprlandWorkspace(wsId)
            
            property int coreHeight: (Config.bar.height || 40) - (Appearance.sizes.padding * 2)
            
            property bool isFocused: Hyprland.focusedWorkspace && Hyprland.focusedWorkspace.id === wsId
            property bool hasWindows: activeWsObject ? (activeWsObject.clients.length > 0) : false
            property bool existsInHyprland: activeWsObject !== null             

            property int leftId: index > 0 ? (workspaces.getSortedWorkspaceIds()[index - 1] ?? -999) : -999
            property int rightId: index < repeater.count - 1 ? (workspaces.getSortedWorkspaceIds()[index + 1] ?? -999) : -999
            
            property bool leftNeighborConnected: !isFocused && hasWindows && workspaces.checkOccupied(leftId) && !workspaces.checkFocused(leftId)
            property bool rightNeighborConnected: !isFocused && hasWindows && workspaces.checkOccupied(rightId) && !workspaces.checkFocused(rightId)

            property color backgroundColor: {
                if (isFocused) return Appearance.colors.accent
                if (hasWindows) {
                    var c = Appearance.colors.surface
                    return Qt.rgba(c.r, c.g, c.b, 0.4)
                }
                if (existsInHyprland) return Appearance.colors.surface
                return "transparent" 
            }
            
            width: coreHeight + (rightNeighborConnected ? 0 : Appearance.sizes.padding)
            height: coreHeight
            
            
            Rectangle {
                id: wsRect
                width: parent.coreHeight
                height: parent.coreHeight
                anchors.left: parent.left
                
                property real r: Appearance.sizes.cornerRadiusSmall
                
                topLeftRadius: delegate.leftNeighborConnected ? 0 : r
                bottomLeftRadius: delegate.leftNeighborConnected ? 0 : r
                
                topRightRadius: delegate.rightNeighborConnected ? 0 : r
                bottomRightRadius: delegate.rightNeighborConnected ? 0 : r
                
                color: delegate.backgroundColor
                
                Behavior on color { ColorAnimation { duration: Appearance.animation.duration } }
                Behavior on topLeftRadius { NumberAnimation { duration: Appearance.animation.duration } }
                Behavior on bottomLeftRadius { NumberAnimation { duration: Appearance.animation.duration } }
                Behavior on topRightRadius { NumberAnimation { duration: Appearance.animation.duration } }
                Behavior on bottomRightRadius { NumberAnimation { duration: Appearance.animation.duration } }

                Text {
                    anchors.centerIn: parent
                    text: workspaces.getWorkspaceLabel(delegate.wsId)
                    font.family: Appearance.font.family.main
                    font.pixelSize: Appearance.font.pixelSize.normal
                    font.weight: delegate.isFocused ? Font.DemiBold : Font.Normal
                    color: {
                        if (delegate.isFocused) return Colors.isDark(delegate.backgroundColor) ? Appearance.colors.text : Appearance.colors.colOnPrimary
                        if (delegate.hasWindows) return Appearance.colors.text
                        return Appearance.colors.textSecondary
                    }
                }
                
                MouseArea {
                    anchors.fill: parent
                    onClicked: Hyprland.dispatch("workspace " + delegate.wsId)
                }
            }
        }
    }
}