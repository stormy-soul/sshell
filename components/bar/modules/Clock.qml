import QtQuick
import "../../../settings"
import "../../../services"

Rectangle {
    id: clockModule

    implicitWidth: row.implicitWidth + Appearance.sizes.padding * 2
    implicitHeight: parent.height - Appearance.sizes.paddingSmall

    radius: Appearance.sizes.cornerRadiusSmall
    color: "transparent"
    
    Row {
        id: row
        anchors.centerIn: parent
        spacing: Appearance.sizes.padding

        Text {
            text: Qt.formatTime(Clock.now, "hh:mm")
            font.family: Appearance.font.family.main
            font.pixelSize: Appearance.font.pixelSize.normal
            font.weight: Font.Medium
            color: Appearance.colors.text
            verticalAlignment: Text.AlignVCenter
        }

        Text {
            text: Qt.formatDate(Clock.now, "MMM dd")
            font.family: Appearance.font.family.main
            font.pixelSize: Appearance.font.pixelSize.normal
            color: Appearance.colors.textSecondary
            verticalAlignment: Text.AlignVCenter
        }
    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        
        onEntered: parent.color = Appearance.colors.surfaceVariant
        onExited: parent.color = "transparent"
    }
}