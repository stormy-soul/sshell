import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import "../../../../settings"
import "../../../../services"
import "../../../common"

PanelWindow {
    id: root
    
    property string position: Config.bar.position || "bottom"
    property Item sourceItem: null
    property real sourceCenter: sourceItem ? sourceItem.mapToGlobal(sourceItem.width/2, 0).x : 0
    
    anchors {
        bottom: position === "bottom"
        top: position === "top"
        left: true 
    }
    
    margins {
        bottom: position === "bottom" ? Appearance.sizes.barMargin: 0
        top: position === "top" ? Appearance.sizes.barMargin: 0
        left: Math.max(Appearance.sizes.paddingLarge, (sourceCenter - (contentLayout.width / 2)))
    }
    
    implicitWidth: contentLayout.width + (Appearance.sizes.padding * 3)
    implicitHeight: contentLayout.height + (Appearance.sizes.padding * 3)
    
    property bool shown: false
    visible: shown
    mask: Region {
        item: ShellState.masterVisible ? background : null
    } 
    
    color: "transparent"

    WlrLayershell.namespace: "sshell:popup"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
    
    property bool popupHovered: hoverHandler.hovered
    
    HoverHandler {
        id: hoverHandler
    }
    
    Rectangle {
        id: background
        anchors.fill: parent
        color: Appearance.colors.overlayBackground
        radius: Appearance.sizes.cornerRadiusLarge
        border.width: 1
        border.color: Qt.rgba(Appearance.colors.border.r, Appearance.colors.border.g, Appearance.colors.border.b, 0.2)
        
        ColumnLayout {
            id: contentLayout
            anchors.centerIn: parent
            spacing: 8
            
            RowLayout {
                Layout.fillWidth: true
                spacing: 8
                
                MaterialIcon {
                    icon: "battery_full"
                    width: Appearance.font.pixelSize.normal
                    height: Appearance.font.pixelSize.normal
                    color: Appearance.colors.accent
                }
                
                Text {
                    text: "Battery"
                    font.family: Appearance.font.family.main
                    font.pixelSize: Appearance.font.pixelSize.normal
                    font.weight: Font.Bold
                    color: Appearance.colors.text
                    Layout.fillWidth: true
                }
            }
            
            RowLayout {
                Layout.fillWidth: true
                spacing: 8
                visible: {
                    let timeValue = Battery.isCharging ? Battery.timeToFull : Battery.timeToEmpty
                    let power = Battery.energyRate
                    return !(Battery.chargeState === 4 || timeValue <= 0 || power <= 0.01)
                }
                
                Text {
                    text: Battery.isCharging ? "Time to full" : "Time to empty"
                    font.family: Appearance.font.family.main
                    font.pixelSize: Appearance.font.pixelSize.small
                    color: Appearance.colors.textSecondary
                }
                
                Item { Layout.fillWidth: true }
                
                Text {
                    text: {
                        function formatTime(seconds) {
                            var h = Math.floor(seconds / 3600)
                            var m = Math.floor((seconds % 3600) / 60)
                            if (h > 0) return h + "h, " + m + "m"
                            return m + "m"
                        }
                        return formatTime(Battery.isCharging ? Battery.timeToFull : Battery.timeToEmpty)
                    }
                    font.family: Appearance.font.family.main
                    font.pixelSize: Appearance.font.pixelSize.small
                    color: Appearance.colors.text
                }
            }
            
            RowLayout {
                Layout.fillWidth: true
                spacing: 8
                visible: !(Battery.chargeState !== 4 && Battery.energyRate === 0)
                
                Text {
                    text: {
                        if (Battery.chargeState === 4) return "Fully charged"
                        if (Battery.chargeState === 1) return "Charging"
                        return "Discharging"
                    }
                    font.family: Appearance.font.family.main
                    font.pixelSize: Appearance.font.pixelSize.small
                    color: Appearance.colors.textSecondary
                }
                
                Item { Layout.fillWidth: true }
                
                Text {
                    text: Battery.chargeState === 4 ? "" : Battery.energyRate.toFixed(2) + "W"
                    font.family: Appearance.font.family.main
                    font.pixelSize: Appearance.font.pixelSize.small
                    color: Appearance.colors.text
                }
            }
            
            RowLayout {
                Layout.fillWidth: true
                spacing: 8
                
                Text {
                    text: "Power source"
                    font.family: Appearance.font.family.main
                    font.pixelSize: Appearance.font.pixelSize.small
                    color: Appearance.colors.textSecondary
                }
                
                Item { Layout.fillWidth: true }
                
                Text {
                    text: {
                        if (SystemInfo.isDesktop) return "AC Power"
                        if (Battery.isCharging) return "AC (Charging)"
                        return "Battery"
                    }
                    font.family: Appearance.font.family.main
                    font.pixelSize: Appearance.font.pixelSize.small
                    color: Appearance.colors.text
                }
            }
            
            RowLayout {
                Layout.fillWidth: true
                spacing: 8
                
                Text {
                    text: "Health"
                    font.family: Appearance.font.family.main
                    font.pixelSize: Appearance.font.pixelSize.small
                    color: Appearance.colors.textSecondary
                }
                
                Item { Layout.fillWidth: true }
                
                Text {
                    text: Battery.health.toFixed(1) + "%"
                    font.family: Appearance.font.family.main
                    font.pixelSize: Appearance.font.pixelSize.small
                    color: Appearance.colors.text
                }
            }
        }
    }
}
