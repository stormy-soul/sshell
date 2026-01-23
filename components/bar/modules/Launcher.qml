import QtQuick
import "../../../settings"
import "../../../services"
import "../../common"

Rectangle {
    id: launcherButton
    width: Appearance.sizes.barHeight
    height: Appearance.sizes.barHeight
    color: "transparent"
    radius: Appearance.sizes.cornerRadiusSmall
    
    MaterialSymbol {
        anchors.centerIn: parent
        text: "apps"
        size: 18
        color: hoverArea.containsMouse ? Appearance.colors.accent : Appearance.colors.text
        fill: hoverArea.containsMouse ? 1 : 0
    }
    
    MouseArea {
        id: hoverArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        
        onClicked: {
            ModuleLoader.launcherVisible = !ModuleLoader.launcherVisible
        }
    }
}