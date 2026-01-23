import QtQuick
import "../../settings"
import "../../services"
import "../common"

Rectangle {
    id: root
    
    required property var entry
    property bool highlighted: false
    readonly property bool isValid: entry && typeof entry === "object"

    width: ListView.view ? ListView.view.width : 300
    height: Appearance.sizes.resultItemHeight
    radius: Appearance.sizes.cornerRadiusSmall
    color: highlighted ? Appearance.colors.accent + "20" : (mouseArea.containsMouse ? Appearance.colors.surface : "transparent")
    
    visible: isValid 

    Row {
        anchors.fill: parent
        anchors.margins: Appearance.sizes.padding
        spacing: Appearance.sizes.padding
        visible: root.isValid
        
        Loader {
            anchors.verticalCenter: parent.verticalCenter
            
            sourceComponent: {
                if (!root.isValid) return undefined
                return (entry.iconType === "material") ? materialIconComponent : systemIconComponent
            }
            
            Component {
                id: materialIconComponent
                MaterialSymbol {
                    size: Appearance.sizes.resultIconSize
                    color: Appearance.colors.accent
                    text: root.isValid ? entry.icon : ""
                    fill: 1
                }
            }
            
            Component {
                id: systemIconComponent
                Icon {
                    source: root.isValid ? entry.icon : ""
                    size: Appearance.sizes.resultIconSize
                    color: Appearance.colors.accent
                }
            }
        }
        
        Column {
            width: parent.width - 48
            anchors.verticalCenter: parent.verticalCenter
            spacing: 2
            
            Text {
                text: root.isValid ? (entry.name || "") : ""
                font.family: Appearance.font.family.main
                font.pixelSize: Appearance.font.pixelSize.normal
                color: Appearance.colors.text
                elide: Text.ElideRight
                width: parent.width
            }
            
            Text {
                text: root.isValid ? (entry.description || "") : ""
                font.family: Appearance.font.family.main
                font.pixelSize: Appearance.font.pixelSize.small
                color: Appearance.colors.textSecondary
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
                ModuleLoader.launcherVisible = false
            }
        }
    }
}