import QtQuick
import "../../../settings"
import "../../../services"
import "../modules/popups"

Rectangle {
    id: clockModule

    implicitWidth: row.implicitWidth + Appearance.sizes.padding * 2
    implicitHeight: 30

    radius: Appearance.sizes.cornerRadiusSmall
    color: "transparent"
    
    property bool hovered: mouseArea.containsMouse
    property bool shouldShowPopup: clockModule.hovered || popup.popupHovered
    
    Timer {
        id: closeDelayTimer
        interval: 150
        onTriggered: {
            if (!clockModule.shouldShowPopup) {
                popup.shown = false
            }
        }
    }
    
    onShouldShowPopupChanged: {
        if (shouldShowPopup) {
            closeDelayTimer.stop()
            popup.shown = true
        } else {
            closeDelayTimer.restart()
        }
    }
    
    Row {
        id: row
        anchors.centerIn: parent
        spacing: Appearance.sizes.padding

        Text {
            text: Qt.formatTime(Clock.now, Config.clock.format === 24 ? "hh:mm" : "hh:mm AP")
            font.family: Appearance.font.family.main
            font.pixelSize: Appearance.font.pixelSize.normal
            font.weight: Font.Medium
            color: Appearance.colors.text
            verticalAlignment: Text.AlignVCenter
            anchors.verticalCenter: parent.verticalCenter
        }

        Text {
            visible: Config.clock.showDate
            text: Qt.formatDate(Clock.now, "MMM dd")
            font.family: Appearance.font.family.main
            font.pixelSize: Appearance.font.pixelSize.normal
            color: Appearance.colors.textSecondary
            verticalAlignment: Text.AlignVCenter
            anchors.verticalCenter: parent.verticalCenter
        }
    }

    MouseArea {
        id: mouseArea
        z: 1
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
    }
    
    ClockPopup {
        id: popup
        sourceItem: clockModule
    }
}