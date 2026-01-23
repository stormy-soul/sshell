import QtQuick
import "../../../settings"
import "../../../services"

Row {
    spacing: Appearance.sizes.padding
    anchors.verticalCenter: parent.verticalCenter

    Rectangle {
        width: 30
        height: 30
        radius: 5
        color: "transparent"
        
        Text {
            anchors.centerIn: parent
            text: "" 
            color: testArea.containsMouse ? Appearance.colors.accent : Appearance.colors.text
            font.pixelSize: Appearance.sizes.fontSizeLarge
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