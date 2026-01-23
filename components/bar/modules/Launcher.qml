import QtQuick
import "../../../theme"
import "../../../services"
import "../../common"
import "../"


Rectangle {
    width: 32
    height: 32
    color: "transparent"
    radius: Theme.cornerRadiusSmall

    MaterialSymbol {
        anchors.centerIn: parent
        text: "apps"
        size: 18
        color: hoverArea.containsMouse ? Theme.accent : Theme.text
        fill: hoverArea.containsMouse ? 1 : 0
    }

    MouseArea {
        id: hoverArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        
        onClicked: {
            ModuleLoader.toggleLauncher()
        }
    }
}