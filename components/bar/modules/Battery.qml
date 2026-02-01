import QtQuick
import "../../../settings"
import "../../../services"
import "../../../components"

Rectangle {
    implicitWidth: row.implicitWidth
    implicitHeight: 30
    color: "transparent"
    
    Row {
        id: row
        anchors.verticalCenter: parent.verticalCenter
        spacing: Appearance.sizes.padding
        
        MaterialIcon {
            id: batIcon
            anchors.verticalCenter: parent.verticalCenter
            width: Appearance.font.pixelSize.extraLarge
            height: Appearance.font.pixelSize.extraLarge * 2
            rotation: 90
            color: {
                if (Battery.isCharging) return Appearance.colors.accent
                if (Battery.percentage <= 0.2) return Appearance.colors.warningCol
                return Appearance.colors.text
            }
            icon: getBatteryIcon()

            function getBatteryIcon() {
                if (Battery.isCharging) return "battery_charging_full"
                
                var p = Battery.percentage
                if (p >= 0.95) return "battery_full"
                if (p >= 0.85) return "battery_6_bar"
                if (p >= 0.70) return "battery_5_bar"
                if (p >= 0.55) return "battery_4_bar"
                if (p >= 0.40) return "battery_3_bar"
                if (p >= 0.25) return "battery_2_bar"
                if (p >= 0.10) return "battery_1_bar"
                return "battery_0_bar"
            }
        }

        Text {
            text: Math.round(Battery.percentage * 100) + "%"
            font.family: Appearance.font.family.main
            font.pixelSize: Appearance.font.pixelSize.normal
            color: Appearance.colors.text
            anchors.verticalCenter: parent.verticalCenter
        }
    }
}