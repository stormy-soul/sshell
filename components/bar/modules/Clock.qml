import QtQuick

import "../../../services"
import "../../../theme"

Rectangle {
    id: clockModule

    implicitWidth: row.implicitWidth + Theme.padding * 2
    implicitHeight: parent.height - Theme.paddingSmall

    radius: Theme.cornerRadiusSmall
    color: "transparent"
    
    Row {
        id: row
        anchors.verticalCenter: parent.verticalCenter
        spacing: Theme.padding

        Text {
            text: Qt.formatTime(Clock.now, "hh:mm")
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSize
            font.weight: Font.Medium
            color: Theme.text
            verticalAlignment: Text.AlignVCenter
        }

        Text {
            text: Qt.formatDate(Clock.now, "MMM dd")
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSize
            color: Theme.textSecondary
            verticalAlignment: Text.AlignVCenter
        }
    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        
        onEntered: parent.color = Theme.surfaceVariant
        onExited: parent.color = "transparent"
    }
}