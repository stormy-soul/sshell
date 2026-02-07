import QtQuick
import QtQuick.Layouts
import "../../../settings"
import "../../../services"
import "../../common"
import "../modules/popups"

Rectangle {
    id: batteryModule
    implicitWidth: row.implicitWidth
    implicitHeight: Config.bar.height
    color: "transparent"
    
    property bool lowBatteryWarned: false
    property bool fullBatteryWarned: false
    property bool hovered: mouseArea.containsMouse
    property bool shouldShowPopup: batteryModule.hovered || popup.popupHovered
    
    Timer {
        id: closeDelayTimer
        interval: 150
        onTriggered: {
            if (!batteryModule.shouldShowPopup) {
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
    
    Connections {
        target: Battery
        function onPercentageChanged() {
            if (Battery.percentage <= 0.10 && !Battery.isCharging) {
                if (!batteryModule.lowBatteryWarned) {
                    NotificationService.push(
                        "Low Battery",
                        "Battery is at " + Math.round(Battery.percentage * 100) + "%. Please plug in your charger!",
                        "battery_alert"
                    )
                    batteryModule.lowBatteryWarned = true
                }
            } else {
                batteryModule.lowBatteryWarned = false
            }

            if (Battery.percentage === 1 && Battery.isCharging) {
                if (!batteryModule.fullBatteryWarned) {
                    NotificationService.push(
                        "Battery Full",
                        "Battery is at 100%. You can unplug your charger!",
                        "battery_full"
                    )
                    batteryModule.fullBatteryWarned = true
                }
            } else if (!Battery.isCharging && Battery.percentage < 0.99) {
                batteryModule.fullBatteryWarned = false
            }
        }
    }
    
    MouseArea {
        id: mouseArea
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        hoverEnabled: true
    }
    
    RowLayout {
        id: row
        anchors.centerIn: parent
        spacing: Appearance.sizes.padding
        
        FluentIcon {
            id: batIcon
            Layout.alignment: Qt.AlignVCenter
            width: Appearance.font.pixelSize.huge
            height: Appearance.font.pixelSize.huge
            color: {
                if (Battery.isCharging) return Appearance.colors.accent
                if (Battery.percentage <= 0.2) return Appearance.colors.warningCol
                return Appearance.colors.text
            }
            icon: getBatteryIcon()

            function getBatteryIcon() {
                if (Battery.isCharging) return "battery-charge"
                
                var p = Battery.percentage
                if (p >= 0.95) return "battery-full"
                if (p >= 0.85) return "battery-9"
                if (p >= 0.75) return "battery-8"
                if (p >= 0.65) return "battery-7"
                if (p >= 0.55) return "battery-6"
                if (p >= 0.45) return "battery-5"
                if (p >= 0.35) return "battery-4"
                if (p >= 0.25) return "battery-3"
                if (p >= 0.15) return "battery-2"
                if (p >= 0.05) return "battery-1"
                return "battery-0"
            }
        }

        Text {
            text: Math.round(Battery.percentage * 100) + "%"
            font.family: Appearance.font.family.main
            font.pixelSize: Appearance.font.pixelSize.normal
            color: Appearance.colors.text
            Layout.alignment: Qt.AlignVCenter
        }
    }
    
    BatteryPopup {
        id: popup
        sourceItem: batteryModule
    }
}