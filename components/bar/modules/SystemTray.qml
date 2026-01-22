import QtQuick
import "../../../theme"
import "../../../services"

Row {
    spacing: Theme.padding
    anchors.verticalCenter: parent.verticalCenter

    Rectangle {
        width: 30
        height: 30
        radius: 5
        color: "transparent"
        
        Text {
            anchors.centerIn: parent
            text: "" 
            color: testArea.containsMouse ? Theme.accent : Theme.text
            font.pixelSize: Theme.fontSizeLarge
        }

        MouseArea {
            id: testArea
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor

            onClicked: {
                console.log("Sending test notification...")
                NotificationService.push("Test", "This is a test notification from the bar!")
            }
        }
    }
}