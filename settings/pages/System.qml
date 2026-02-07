import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Qt5Compat.GraphicalEffects
import "../../services"
import "../../components/settings"
import "../../components/common"
import "../"

ContentPage {
    id: root
    property int gap: Appearance.sizes.paddingLarge
    
    onVisibleChanged: {
        if (root.visible) ResourceMonitor.refreshDisks()
    }

    RowLayout {
        Layout.fillWidth: true
        Layout.bottomMargin: 10
        spacing: Appearance.sizes.paddingLarge
        
        Rectangle {
            Layout.preferredWidth: 100
            Layout.preferredHeight: 100
            color: "transparent"
            radius: Appearance.sizes.cornerRadiusLarge
            
            Image {
                id: osLogo
                anchors.centerIn: parent
                source: SystemInfo.osIconPath || Quickshell.shellPath("assets/icons/linux-symbolic.svg")
                sourceSize.width: 64
                sourceSize.height: 64
                visible: false
            }
            
            ColorOverlay {
                anchors.fill: osLogo
                source: osLogo
                color: Appearance.colors.accent
                antialiasing: true
            }
        }
        
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 5
            
            Text {
                text: SystemInfo.userName + "@" + SystemInfo.hostName
                color: Appearance.colors.text
                font.family: Appearance.font.family.main
                font.pixelSize: Appearance.font.pixelSize.extraLarge
                font.weight: Font.Bold
            }
            
            Text {
                text: SystemInfo.osName
                color: Appearance.colors.textSecondary
                font.family: Appearance.font.family.main
                font.pixelSize: Appearance.font.pixelSize.large
            }
            
            Text {
                text: SystemInfo.kernelVersion
                color: Appearance.colors.textSecondary
                font.family: Appearance.font.family.main
                font.pixelSize: Appearance.font.pixelSize.normal
            }
             
            Text {
                text: SystemInfo.uptime
                color: Appearance.colors.textSecondary
                font.family: Appearance.font.family.main
                font.pixelSize: Appearance.font.pixelSize.normal
            }
        }
    }

    ContentSection {
        title: "System Resources"
        icon: "monitor_heart"
        spacing: Appearance.sizes.paddingLarge
        
        RowLayout {
            Layout.fillWidth: true
            spacing: Appearance.sizes.paddingLarge
            
            SystemCard {
                Layout.fillWidth: true
                Layout.fillHeight: true
                icon: "memory" 
                title: "CPU"
                usagePercent: ResourceMonitor.cpuUsage
                graphData: ResourceMonitor.cpuHistory
                valueText: Math.round(ResourceMonitor.cpuUsage * 100) + "%"
                secondaryText: ResourceMonitor.cpuFreq
            }
            
            SystemCard {
                Layout.fillWidth: true
                Layout.fillHeight: true
                icon: "dns" 
                title: "RAM"
                usagePercent: ResourceMonitor.ramPercent
                secondaryText: {
                    var used = (ResourceMonitor.ramUsage / (1024*1024*1024)).toFixed(1)
                    var total = (ResourceMonitor.ramTotal / (1024*1024*1024)).toFixed(1)
                    return used + " / " + total + " GB"
                }
            }
            
            SystemCard {
                Layout.fillWidth: true
                Layout.fillHeight: true
                icon: "swap_horiz" 
                title: "Swap"
                usagePercent: ResourceMonitor.swapPercent
                 secondaryText: {
                    var used = (ResourceMonitor.swapUsage / (1024*1024*1024)).toFixed(1)
                    var total = (ResourceMonitor.swapTotal / (1024*1024*1024)).toFixed(1)
                    return used + " / " + total + " GB"
                }
            }
        }
        
        RowLayout {
            Layout.fillWidth: true
            Layout.topMargin: Appearance.sizes.paddingLarge
            
            ColumnLayout {
                spacing: Appearance.sizes.paddingLarge

                DiskListCard {
                    Layout.fillWidth: true
                    title: "Root / System"
                    diskModel: ResourceMonitor.diskSystem
                    visible: diskModel.length > 0
                }
                
                DiskListCard {
                    Layout.fillWidth: true
                    title: "Local / Fuse"
                    diskModel: ResourceMonitor.diskUser
                    visible: diskModel.length > 0
                }
                
                DiskListCard {
                    Layout.fillWidth: true
                    title: "Special Devices"
                    diskModel: ResourceMonitor.diskSpecial
                    visible: diskModel.length > 0
                }
            }
        }
    }
    
    ContentSection {
        title: "Details"
        icon: "info"
        space: root.gap

        component InfoRow : RowLayout {
            property string label
            property string value
            Layout.fillWidth: true
            spacing: 10
            
            Text {
                text: label
                color: Appearance.colors.textSecondary
                font.family: Appearance.font.family.main
                font.pixelSize: Appearance.font.pixelSize.normal
                Layout.preferredWidth: 100
            }
            
            Text {
                text: value
                color: Appearance.colors.text
                font.family: Appearance.font.family.main
                font.pixelSize: Appearance.font.pixelSize.normal
                font.weight: Font.Medium
                Layout.fillWidth: true
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 12
            
            InfoRow { label: "OS"; value: SystemInfo.osName }
            InfoRow { label: "Chassis"; value: SystemInfo.chassis }
            InfoRow { label: "Uptime"; value: SystemInfo.uptime }
        }
    }
}