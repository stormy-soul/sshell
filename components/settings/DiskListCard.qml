import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import "../common"
import "../../settings"

Rectangle {
    id: root
    
    property string title: "" 
    property var diskModel: []
    
    implicitWidth: 300
    implicitHeight: layout.implicitHeight + 20
    
    radius: Appearance.sizes.cornerRadiusLarge
    color: Appearance.colors.overlayBackground
    clip: true
    
    ColumnLayout {
        id: layout
        anchors.fill: parent
        anchors.margins: Appearance.sizes.paddingLarge
        spacing: Appearance.sizes.paddingLarge
        
        RowLayout {
            Layout.fillWidth: true
            
            Text {
                text: root.title
                font.family: Appearance.font.family.main
                font.pixelSize: Appearance.font.pixelSize.large
                font.weight: Font.DemiBold
                color: Appearance.colors.text
            }
            
            Item { Layout.fillWidth: true }
            
            Text {
                text: root.diskModel.length + " Devices"
                font.family: Appearance.font.family.main
                font.pixelSize: Appearance.font.pixelSize.small
                color: Appearance.colors.textSecondary
            }
        }
        
        Rectangle {
            Layout.fillWidth: true
            height: 1
            color: Appearance.colors.border
            opacity: 0.5
        }
        
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 20
            
            Repeater {
                model: root.diskModel
                delegate: ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 5
                    
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 10
                        
                        Rectangle {
                            width: 32
                            height: 32
                            radius: 8
                            color: Appearance.colors.surfaceVariant
                            MaterialIcon {
                                anchors.centerIn: parent
                                icon: "storage"
                                width: 20
                                height: 20
                                color: Appearance.colors.accent
                            }
                        }
                        
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 0
                            
                            Text {
                                text: modelData.name
                                font.family: Appearance.font.family.main
                                font.pixelSize: Appearance.font.pixelSize.normal
                                font.weight: Font.Medium
                                color: Appearance.colors.text
                                elide: Text.ElideMiddle
                                Layout.fillWidth: true
                            }
                            
                            Text {
                                text: modelData.mount
                                font.family: Appearance.font.family.main
                                font.pixelSize: Appearance.font.pixelSize.tiny
                                color: Appearance.colors.textSecondary
                                elide: Text.ElideMiddle
                                Layout.fillWidth: true
                            }
                        }
                        
                        Text {
                            function formatSize(bytes) {
                                var gb = bytes / (1024*1024*1024)
                                if (gb >= 1) return gb.toFixed(1) + " GB"
                                var mb = bytes / (1024*1024)
                                return mb.toFixed(1) + " MB"
                            }
                            
                            text: formatSize(modelData.used) + " / " + formatSize(modelData.total)
                            font.family: Appearance.font.family.main
                            font.pixelSize: Appearance.font.pixelSize.small
                            color: Appearance.colors.text
                        }
                    }
                    
                    Rectangle {
                        Layout.fillWidth: true
                        height: 6
                        radius: 3
                        color: Appearance.colors.surfaceVariant
                        
                        Rectangle {
                            height: parent.height
                            radius: 3
                            width: parent.width * modelData.percent
                            color: {
                                if (modelData.percent > 0.9) return "red"
                                return Appearance.colors.accent
                            }
                        }
                    }
                }
            }
        }
    }
}
