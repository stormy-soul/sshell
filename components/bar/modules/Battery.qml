import QtQuick
import Qt5Compat.GraphicalEffects
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
        
        Item {
            width: bgIcon.implicitWidth
            height: bgIcon.implicitHeight
            anchors.verticalCenter: parent.verticalCenter
            
            property int batteryWarnLevel: 20
            property color iconColor: {
                if (Battery.percentage >= 1.0) return Appearance.colors.successCol
                if (Battery.percentage * 100 <= batteryWarnLevel) return Appearance.colors.warningCol
                return Appearance.colors.textSecondary
            }
            
            Image {
                id: bgIcon
                anchors.centerIn: parent
                source: "file://" + Directories.assetsPath + "/icons/fluent/" + getBatteryIcon() + ".svg"
                sourceSize.height: Appearance.font.pixelSize.small -  Appearance.sizes.paddingTiny
                sourceSize.width: sourceSize.height * 2
                fillMode: Image.PreserveAspectFit
                visible: false
                
                function getBatteryIcon() {
                    if (Battery.isCharging) return "battery-charge"
                    
                    var level = Math.floor(Battery.percentage * 10)
                    if (level >= 10) return "battery-full"
                    if (level < 0) return "battery-0"
                    
                    return "battery-" + level
                }
            }
            
            ColorOverlay {
                anchors.fill: bgIcon
                source: bgIcon
                color: parent.iconColor
            }
        }

        Text {
            text: Math.round(Battery.percentage * 100) + "%"
            font.family: Appearance.font.family.main
            font.pixelSize: Appearance.font.pixelSize.small
            color: Appearance.colors.textSecondary
            anchors.verticalCenter: parent.verticalCenter
        }
    }
}