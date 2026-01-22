import QtQuick
import Quickshell.Hyprland

Row {
    id: workspaces
    spacing: Theme.paddingSmall
    
    Repeater {
        model: Hyprland.workspaces
        
        Rectangle {
            required property var modelData
            
            width: 32
            height: parent.parent.height - Theme.paddingSmall
            radius: Theme.cornerRadiusSmall
            
            property bool isActive: Hyprland.focusedWorkspace ? Hyprland.focusedWorkspace.id === modelData.id : false
            property bool hasWindows: modelData.windows.length > 0
            
            color: {
                if (isActive) return Theme.accent
                if (hasWindows) return Theme.surface
                return "transparent"
            }
            
            Behavior on color {
                ColorAnimation { duration: Theme.animationDuration }
            }
            
            Text {
                anchors.centerIn: parent
                text: parent.modelData.id
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSize
                font.weight: parent.isActive ? Font.DemiBold : Font.Normal
                color: parent.isActive ? Theme.background : Theme.text
            }
            
            MouseArea {
                anchors.fill: parent
                onClicked: {
                    Hyprland.dispatch("workspace " + parent.modelData.id)
                }
            }
        }
    }
}