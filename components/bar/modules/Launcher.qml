import QtQuick

Rectangle {
    id: launcherButton
    width: 32
    height: parent.height - Theme.paddingSmall
    radius: Theme.cornerRadiusSmall
    color: mouseArea.containsMouse ? Theme.accent : Theme.surface
    
    Behavior on color {
        ColorAnimation { duration: Theme.animationDurationFast }
    }
    
    Text {
        anchors.centerIn: parent
        text: "󰀻" // Grid icon
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSizeLarge
        color: Theme.text
    }
    
    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        
        onClicked: {
            launcherWindow.visible = !launcherWindow.visible
        }
    }
}