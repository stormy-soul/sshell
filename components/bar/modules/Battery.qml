import QtQuick
import "../../../theme"

Rectangle {
    implicitWidth: row.implicitWidth
    implicitHeight: 30
    color: "transparent"
    
    Row {
        id: row
        anchors.verticalCenter: parent.verticalCenter
        spacing: Theme.padding

        Text {
            text: " " 
            color: Theme.accent
            verticalAlignment: Text.AlignVCenter
            font.pixelSize: Theme.fontSize
        }
    }
}