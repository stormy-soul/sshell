import QtQuick
import Quickshell
import Quickshell.Hyprland
import "../../../settings"
import "../../../services"

Item {
    id: root
    
    readonly property int buttonHeight: (Config.bar.height || 40) - (Appearance.sizes.padding * 2)
    readonly property int buttonWidth: buttonHeight
    readonly property int buttonRadius: Config.workspaces.radius === "circle" ? Appearance.sizes.cornerRadiusLarge : Config.workspaces.radius === "rounded" ? Appearance.sizes.cornerRadiusSmall : 0
    
    implicitWidth: row.width
    implicitHeight: buttonHeight
    
    function getSortedWorkspaceIds() {
        if (!Hyprland.workspaces || !Hyprland.workspaces.values) return Config.workspaces.persistent
        
        let ids = new Set(Config.workspaces.persistent)
        const wsList = Hyprland.workspaces.values
        
        for (let i = 0; i < wsList.length; i++) {
            ids.add(wsList[i].id)
        }
        
        return Array.from(ids).sort((a, b) => a - b)
    }
    
    function checkOccupied(id) {
        if (!Hyprland.workspaces || !Hyprland.workspaces.values) return false
        var params = Hyprland.workspaces.values
        for (let i = 0; i < params.length; i++) {
             if (params[i].id === id) return true
        }
        return false
    }

    function getIndexOf(id) {
        var ids = root.workspaceIds
        return ids.indexOf(id)
    }

    property var workspaceIds: {
        if (Hyprland.workspaces) {
             var _trigger = Hyprland.workspaces.values
        }
        return getSortedWorkspaceIds()
    }

    Row {
        id: bgRow
        anchors.fill: parent
        spacing: 0
        
        Repeater {
            model: root.workspaceIds
            
            Rectangle {
                id: bgRect
                readonly property int wsId: modelData
                
                property bool isOccupied: {
                    if (Hyprland.workspaces) var _t = Hyprland.workspaces.values
                    return root.checkOccupied(wsId)
                }
                
                readonly property bool isActive: Hyprland.focusedWorkspace && Hyprland.focusedWorkspace.id === wsId
                
                width: root.buttonWidth
                height: root.buttonHeight
                
                readonly property int prevId: index > 0 ? root.workspaceIds[index - 1] : -999
                readonly property int nextId: index < root.workspaceIds.length - 1 ? root.workspaceIds[index + 1] : -999
                
                readonly property bool prevOccupied: index > 0 && root.checkOccupied(prevId)
                readonly property bool nextOccupied: index < root.workspaceIds.length - 1 && root.checkOccupied(nextId)
                
                color: isOccupied ? Appearance.colors.surfaceVariant : "transparent"
                opacity: isOccupied ? 0.5 : 0
                
                property real r: root.buttonRadius
                
                topLeftRadius: prevOccupied ? 0 : r
                bottomLeftRadius: prevOccupied ? 0 : r
                topRightRadius: nextOccupied ? 0 : r
                bottomRightRadius: nextOccupied ? 0 : r
                
                Behavior on opacity { NumberAnimation { duration: Appearance.animation.duration } }
                Behavior on topLeftRadius { NumberAnimation { duration: Appearance.animation.duration } }
                Behavior on topRightRadius { NumberAnimation { duration: Appearance.animation.duration } }
                Behavior on bottomLeftRadius { NumberAnimation { duration: Appearance.animation.duration } }
                Behavior on bottomRightRadius { NumberAnimation { duration: Appearance.animation.duration } }
                Behavior on color { ColorAnimation { duration: Appearance.animation.duration } }
            }
        }
    }
    
    Rectangle {
        id: indicator
        
        property int activeIndex: {
            if (!Hyprland.focusedWorkspace) return -1
            return root.getIndexOf(Hyprland.focusedWorkspace.id)
        }
        
        visible: activeIndex !== -1
        
        x: activeIndex * root.buttonWidth
        y: 0
        width: root.buttonWidth
        height: root.buttonHeight
        
        radius: root.buttonRadius
        color: Appearance.colors.accent
        
        Behavior on x { 
            NumberAnimation { 
                duration: Appearance.animation.duration 
                easing.type: Easing.OutCubic
            } 
        }
    }
    
    Row {
        id: row
        spacing: 0
        
        Repeater {
            model: root.workspaceIds
            
            Item {
                id: fgDelegate
                readonly property int wsId: modelData
                readonly property bool isActive: Hyprland.focusedWorkspace && Hyprland.focusedWorkspace.id === wsId
                readonly property bool isOccupied: root.checkOccupied(wsId)
                
                width: root.buttonWidth
                height: root.buttonHeight
                
                function getLabel(id) {
                    var style = Config.workspaces.style || "arabic"
                    if (style === "roman") {
                        var romals = ["", "I", "II", "III", "IV", "V", "VI", "VII", "VIII", "IX", "X"]
                        return (id > 0 && id <= 10) ? romals[id] : id.toString()
                    }
                    if (style === "han") {
                        var hans = ["", "一", "二", "三", "四", "五", "六", "七", "八", "九", "十"]
                        return (id > 0 && id <= 10) ? hans[id] : id.toString()
                    }
                    if (style === "dot") return ""
                    return id.toString()
                }

                Text {
                    anchors.centerIn: parent
                    text: fgDelegate.getLabel(wsId)
                    
                    font.family: Appearance.font.family.main
                    font.pixelSize: Appearance.font.pixelSize.normal
                    font.weight: isActive ? Font.Bold : Font.DemiBold
                    
                    color: {
                        if (isActive) return Appearance.colors.colOnPrimary
                        if (isOccupied) return Appearance.colors.text       
                        return Appearance.colors.textSecondary              
                    }
                    
                    Behavior on color { ColorAnimation { duration: Appearance.animation.duration } }
                }
                
                Rectangle {
                    anchors.centerIn: parent
                    visible: Config.workspaces.style === "dot"
                    
                    width: 8
                    height: 8
                    radius: Appearance.sizes.cornerRadiusHuge
                    
                    color: {
                        if (isActive) return Appearance.colors.colOnPrimary
                        if (isOccupied) return Appearance.colors.text
                        return Appearance.colors.textSecondary
                    }
                    
                    Behavior on width { NumberAnimation { duration: Appearance.animation.duration; easing.type: Easing.OutBack } }
                    Behavior on height { NumberAnimation { duration: Appearance.animation.duration; easing.type: Easing.OutBack } }
                    Behavior on color { ColorAnimation { duration: Appearance.animation.duration } }
                }
                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: Hyprland.dispatch("workspace " + wsId)
                    onEntered: {
                        if (!isActive) {
                        }
                    }
                }
            }
        }
    }
}