import QtQuick
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects
import Quickshell
import "../../settings"
import "../../services"

Rectangle {
    id: root
    
    visible: OSD.visible
    opacity: visible ? 1 : 0
    
    Behavior on opacity {
        NumberAnimation { duration: Appearance.animation.duration }
    }
    
    implicitWidth: osdContent.width + 24
    implicitHeight: osdContent.height + 20
    
    color: Appearance.colors.overlayBackground
    radius: Appearance.sizes.cornerRadiusLarge
    border.width: 1
    border.color: Qt.rgba(Appearance.colors.border.r, Appearance.colors.border.g, Appearance.colors.border.b, 0.2)
        
    RowLayout {
        id: osdContent
        anchors.centerIn: parent
        spacing: 12
        
        MaterialIcon {
            icon: OSD.icon
            width: 28
            height: 28
            color: Appearance.colors.accent
            Layout.alignment: Qt.AlignVCenter
        }
        
        ColumnLayout {
            spacing: 4
            Layout.alignment: Qt.AlignVCenter
            
            Text {
                visible: OSD.label !== "" || OSD.text !== ""
                text: OSD.label !== "" ? OSD.label : OSD.text
                color: Appearance.colors.text
                font.family: Appearance.font.family.main
                font.pixelSize: Appearance.font.pixelSize.normal
                font.bold: true
            }
            
            RowLayout {
                visible: OSD.value >= 0
                spacing: 8
                
                Rectangle {
                    Layout.preferredWidth: 150
                    Layout.preferredHeight: 5
                    radius: 2.5
                    color: Qt.rgba(Appearance.colors.text.r, Appearance.colors.text.g, Appearance.colors.text.b, 0.2)
                    
                    Rectangle {
                        width: parent.width * Math.min(1, Math.max(0, OSD.value / 100))
                        height: parent.height
                        radius: 2.5
                        color: Appearance.colors.accent
                        
                        Behavior on width {
                            NumberAnimation { duration: 50 }
                        }
                    }
                }
                
                Text {
                    text: Math.round(OSD.value) + "%"
                    color: Appearance.colors.textSecondary
                    font.family: Appearance.font.family.main
                    font.pixelSize: Appearance.font.pixelSize.small
                    Layout.preferredWidth: 30
                }
            }
        }
    }
}
