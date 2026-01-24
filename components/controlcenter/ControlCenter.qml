import QtQuick
import "../../settings"

Rectangle {
    id: root
    
    color: Appearance.colors.overlayBackground
    radius: Appearance.sizes.cornerRadius
    border.width: 1
    border.color: Appearance.colors.border
    clip: true
    
    opacity: 0
    visible: true 
    
    Component.onCompleted: opacity = 1
    Behavior on opacity { NumberAnimation { duration: Appearance.animation.duration } }
    
    Text {
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.leftMargin: Appearance.sizes.paddingExtraLarge
        anchors.topMargin: Appearance.sizes.paddingExtraLarge
        text: "Control Center"
        color: Appearance.colors.textSecondary
        font.family: Appearance.font.family.main
        font.pixelSize: Appearance.font.pixelSize.massive
    }
    
    Keys.onEscapePressed: {
    }
}