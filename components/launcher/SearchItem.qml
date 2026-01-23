import QtQuick
import "../../theme"
import "../../services"
import "../common"

Rectangle {
    id: root
    
    // Allow entry to be null/undefined without crashing
    required property var entry
    
    // Safety check: is the entry valid?
    readonly property bool isValid: entry && typeof entry === "object"

    width: ListView.view ? ListView.view.width : 300
    height: 56
    radius: Theme.cornerRadiusSmall
    color: (mouseArea.containsMouse || (entry && entry.active)) ? Theme.surface : "transparent"
    
    // Don't render content if invalid
    visible: isValid 

    Row {
        anchors.fill: parent
        anchors.margins: Theme.padding
        spacing: Theme.padding
        visible: root.isValid
        
        // Icon Loader
        Loader {
            anchors.verticalCenter: parent.verticalCenter
            
            // Safe access to iconType
            sourceComponent: {
                if (!root.isValid) return undefined
                return (entry.iconType === "material") ? materialIconComponent : systemIconComponent
            }
            
            Component {
                id: materialIconComponent
                MaterialSymbol {
                    size: 32
                    color: Theme.accent
                    text: root.isValid ? entry.icon : ""
                    fill: 1
                }
            }
            
            Component {
                id: systemIconComponent
                Icon {
                    source: root.isValid ? entry.icon : ""
                    size: 32
                    color: Theme.accent
                }
            }
        }
        
        // Text Column
        Column {
            width: parent.width - 48
            anchors.verticalCenter: parent.verticalCenter
            spacing: 2
            
            Text {
                // Safe access to name
                text: root.isValid ? (entry.name || "") : ""
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSize
                color: Theme.text
                elide: Text.ElideRight
                width: parent.width
            }
            
            Text {
                // Safe access to description
                text: root.isValid ? (entry.description || "") : ""
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSizeSmall
                color: Theme.textSecondary
                elide: Text.ElideRight
                width: parent.width
                visible: text.length > 0
            }
        }
    }
    
    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        
        onClicked: {
            if (root.isValid && entry.execute) {
                entry.execute()
                // Close launcher (Use simple visibility check if ModuleLoader unavailable)
                if (root.ListView.view && root.ListView.view.parent && root.ListView.view.parent.parent) {
                     // Try to find the window to close it, or rely on execute side effects
                }
            }
        }
    }
}