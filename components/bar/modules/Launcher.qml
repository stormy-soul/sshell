import QtQuick
import "../../../theme"
import "../../../services"

Rectangle {
    width: 32
    height: 32
    color: "transparent"
    radius: Theme.cornerRadiusSmall

    Text {
        anchors.centerIn: parent
        text: "" // Arch Logo or use "󰣇"
        font.family: Theme.fontFamily
        font.pixelSize: 18
        color: hoverArea.containsMouse ? Theme.accent : Theme.text
    }

    MouseArea {
        id: hoverArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        
        onClicked: {
            Config.toggleLauncher()
        }
    }
}