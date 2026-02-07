import QtQuick
import QtQuick.Layouts
import "../../../settings"
import "../../../services"
import "../modules/popups"
import "../../../components"
Rectangle {
    id: clockModule

    implicitWidth: row.implicitWidth
    implicitHeight: Config.bar.height

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
    
    RowLayout {
        id: row
        anchors.centerIn: parent
        spacing: Appearance.sizes.padding

        MaterialIcon {
            icon: "wb_sunny"
            width: Appearance.font.pixelSize.extraLarge
            height: Appearance.font.pixelSize.extraLarge
            color: Appearance.colors.text
            visible: false
        }

        Text {
            text: Qt.formatTime(Clock.now, Config.clock.format === 24 ? "hh:mm" : "hh:mm AP")
            font.family: Appearance.font.family.main
            font.pixelSize: Appearance.font.pixelSize.normal + 1 // TS will not center otherwise
            color: Appearance.colors.text
            verticalAlignment: Text.AlignVCenter
            Layout.alignment: Qt.AlignVCenter
        }

        Text {
            visible: Config.clock.showDate
            text: Qt.formatDate(Clock.now, "MMM dd")
            font.family: Appearance.font.family.main
            font.pixelSize: Appearance.font.pixelSize.normal + 1 // TS will not center otherwise
            color: Appearance.colors.textSecondary
            verticalAlignment: Text.AlignVCenter
            Layout.alignment: Qt.AlignVCenter
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