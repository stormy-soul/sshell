import QtQuick
import "../../../settings"
import "../../../services"

Rectangle {
    implicitWidth: row.implicitWidth
    implicitHeight: 30
    color: "transparent"
    
    Row {
        id: row
        anchors.verticalCenter: parent.verticalCenter
        spacing: Appearance.sizes.padding

        Text {
            text: " " 
            color: Appearance.colors.accent
            verticalAlignment: Text.AlignVCenter
            font.pixelSize: Appearance.sizes.fontSize
        }
    }
}