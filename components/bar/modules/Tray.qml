import QtQuick
import "../../../settings"
import "../../../services" as Services
import "../../common"

Rectangle {
    id: root
    implicitWidth: row.width + (Appearance.sizes.padding * 2)
    implicitHeight: 30
    color: hoverArea.containsMouse ? Appearance.colors.surfaceHover : "transparent"
    radius: Appearance.sizes.text

    anchors.verticalCenter: parent.verticalCenter

    Row {
        id: row
        spacing: Appearance.sizes.padding
        anchors.centerIn: parent
        
        Rectangle {
            id: bluetoothItem
            implicitHeight: 30
            implicitWidth: btRow.implicitWidth
            color: "transparent"
            visible: true
            
            property bool showName: Config.tray.showBluetoothName
            
            function getIcon() {
                if (!Services.Bluetooth.enabled) return "bluetooth_disabled"
                if (Services.Bluetooth.connected) return "bluetooth_connected"
                return "bluetooth"
            }
            
            Row {
                id: btRow
                anchors.verticalCenter: parent.verticalCenter
                spacing: Appearance.sizes.padding
                
                Item {
                    width: btIcon.width
                    height: btIcon.height
                    anchors.verticalCenter: parent.verticalCenter
                    
                    MaterialIcon {
                        id: btIcon
                        icon: bluetoothItem.getIcon()
                        width: Appearance.font.pixelSize.extraLarge
                        height: Appearance.font.pixelSize.extraLarge
                        color: Appearance.colors.text
                    }
                    
                    Text {
                        visible: Services.Bluetooth.activeDeviceCount > 1
                        text: Services.Bluetooth.activeDeviceCount
                        font.family: Appearance.font.family.main
                        font.pixelSize: Appearance.font.pixelSize.tiny
                        color: Appearance.colors.textSecondary
                        anchors.right: parent.right
                        anchors.bottom: parent.bottom
                        anchors.bottomMargin: -2 
                        anchors.rightMargin: -2
                    }
                }
                
                Text {
                    visible: bluetoothItem.showName && Services.Bluetooth.connected
                    text: Services.Bluetooth.firstDeviceName
                    color: Appearance.colors.textSecondary
                    font.family: Appearance.font.family.main
                    font.pixelSize: Appearance.font.pixelSize.small
                    anchors.verticalCenter: parent.verticalCenter
                }
            }
        }
        
        Rectangle {
            id: networkItem
            implicitHeight: 30
            implicitWidth: netRow.implicitWidth
            color: "transparent"
            visible: true
            
            property bool showName: Config.tray.showNetworkName
            
            function getIcon() {
                if (!Services.Network.wifiEnabled) return "wifi_off"
                if (Services.Network.wifiStatus === "disconnected") return "wifi_find"
                if (Services.Network.wifiStatus === "connecting") return "wifi_find" // signal_wifi_statusbar_not_connected not found in list? using wifi_find or signal_wifi_bad
                
                var s = Services.Network.signalStrength
                if (s >= 80) return "signal_wifi_4_bar"
                if (s >= 60) return "network_wifi" 
                if (s >= 40) return "network_wifi_3_bar" 
                if (s >= 20) return "signal_wifi_1_bar" // Fallback mostly
                return "signal_wifi_0_bar"
            }
            
            Row {
                id: netRow
                anchors.verticalCenter: parent.verticalCenter
                spacing: Appearance.sizes.padding
                
                MaterialIcon {
                    icon: networkItem.getIcon()
                    width: Appearance.font.pixelSize.extraLarge
                    height: Appearance.font.pixelSize.extraLarge
                    color: Appearance.colors.text
                    anchors.verticalCenter: parent.verticalCenter
                }
                
                Text {
                    visible: networkItem.showName && Services.Network.wifiStatus === "connected"
                    text: Services.Network.ssid
                    color: Appearance.colors.textSecondary
                    font.family: Appearance.font.family.main
                    font.pixelSize: Appearance.font.pixelSize.small
                    anchors.verticalCenter: parent.verticalCenter
                }
            }
        }
    }
    
    MouseArea {
        id: hoverArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: Services.ModuleLoader.toggleControlCenter()
    }
}