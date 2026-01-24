import QtQuick
import "../../settings"
import "../../services"
import "../common"

Rectangle {
    id: root
    
    required property var entry
    property bool highlighted: false
    readonly property bool isValid: entry && typeof entry === "object"
    
    property int horizontalMargin: Appearance.sizes.padding

    width: ListView.view ? ListView.view.width : 300
    height: (entry.type === "clipboard" && Clipboard.isImage(entry.name || "")) ? 200 : Appearance.sizes.resultItemHeight
    radius: Appearance.sizes.cornerRadius
    
    color: {
        if (highlighted) return Appearance.colors.highlightBg
        if (mouseArea.containsMouse) return Appearance.colors.highlightBgHover
        return "transparent"
    }
    
    visible: isValid 
    
    Behavior on color {
        ColorAnimation {
            duration: Appearance.animation.durationFast
            easing.type: Appearance.animation.easingDefault
        }
    }

    Row {
        anchors.fill: parent
        anchors.leftMargin: root.horizontalMargin
        anchors.rightMargin: root.horizontalMargin
        anchors.topMargin: Appearance.sizes.padding
        anchors.bottomMargin: Appearance.sizes.padding
        spacing: Appearance.sizes.paddingLarge
        visible: root.isValid
        
        Loader {
            anchors.verticalCenter: parent.verticalCenter
            visible: entry.type !== "clipboard" // Hide icon for clipboard
            
            sourceComponent: {
                if (!root.isValid) return undefined
                return (entry.iconType === "material") ? materialIconComponent : systemIconComponent
            }
            
            Component {
                id: materialIconComponent
                MaterialSymbol {
                    size: Appearance.sizes.resultIconSize
                    color: root.highlighted ? Appearance.colors.accent : Appearance.colors.text
                    text: root.isValid ? entry.icon : ""
                    fill: 1
                }
            }
            
            Component {
                id: systemIconComponent
                Icon {
                    source: root.isValid ? entry.icon : ""
                    size: Appearance.sizes.resultIconSize
                }
            }
        }
        
        Column {
            width: {
                if (entry.type === "clipboard") return parent.width - root.horizontalMargin * 2
                return parent.width - Appearance.sizes.resultIconSize - parent.spacing - root.horizontalMargin * 2
            }
            anchors.verticalCenter: parent.verticalCenter
            spacing: 2
            
            Text {
                visible: entry.type === "clipboard"
                text: root.isValid ? ("#" + entry.id) : ""
                font.family: Appearance.font.family.main
                font.pixelSize: Appearance.font.pixelSize.tiny
                font.bold: true
                color: Appearance.colors.textSecondary
            }
            
            Loader {
                active: entry.type === "clipboard" && Clipboard.isImage(entry.name)
                visible: active
                width: parent.width
                height: root.height - 40 
                
                sourceComponent: CliphistImage {
                    entryId: entry.id
                    entryContent: entry.name
                    width: parent.width
                    height: parent.height
                }
            }
            
            Text {
                visible: !(entry.type === "clipboard" && Clipboard.isImage(entry.name))
                text: root.isValid ? (entry.name || "") : ""
                font.family: Appearance.font.family.main
                font.pixelSize: Appearance.font.pixelSize.normal
                color: Appearance.colors.text
                elide: Text.ElideRight
                width: parent.width
            }
            
            Text {
                visible: entry.type !== "clipboard" && text.length > 0
                text: root.isValid ? (entry.description || "") : ""
                font.family: Appearance.font.family.main
                font.pixelSize: Appearance.font.pixelSize.small
                color: Appearance.colors.textSecondary
                elide: Text.ElideRight
                width: parent.width
            }
        }
    }
    
    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        
        onClicked: {
            resultsList.currentIndex = index
            resultsList.forceActiveFocus()
            
            if (root.isValid && entry.execute) {
                entry.execute()
                ModuleLoader.launcherVisible = false
            }
        }
    }
}