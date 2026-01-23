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

    Icon {
        anchors.centerIn: parent
        source: "" 
        size: 18
        color: hoverArea.containsMouse ? Theme.accent : Theme.text
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