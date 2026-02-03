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
    property real sourceCenter: {
        if (!sourceItem || sourceItem.width <= 0) return -1
        var mapped = sourceItem.mapToGlobal(sourceItem.width/2, 0)
        return mapped.x > 0 ? mapped.x : -1
    }
    
    anchors {
        bottom: position === "bottom"
        top: position === "top"
        left: true 
    }
    
    margins {
        bottom: position === "bottom" ? Appearance.sizes.barMargin : 0
        top: position === "top" ? Appearance.sizes.barMargin : 0
        left: sourceCenter > 0 ? Math.max(Appearance.sizes.paddingLarge, (sourceCenter - (contentLayout.width / 2))) : Appearance.sizes.paddingLarge
    }
    
    implicitWidth: Math.max(240, contentLayout.width + (Appearance.sizes.padding * 3))
    implicitHeight: Math.max(120, contentLayout.height + (Appearance.sizes.padding * 3))
    
    property bool shown: false
    visible: shown && sourceCenter > 0
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
            spacing: Appearance.sizes.padding
            width: 240
            
            RowLayout {
                Layout.fillWidth: true
                spacing: Appearance.sizes.padding
                
                MaterialIcon {
                    icon: "timer"
                    width: Appearance.font.pixelSize.normal
                    height: Appearance.font.pixelSize.normal
                    color: Appearance.colors.accent
                }
                
                Text {
                    text: "Clock"
                    font.family: Appearance.font.family.main
                    font.pixelSize: Appearance.font.pixelSize.large
                    font.weight: Font.Bold
                    color: Appearance.colors.text
                }
            }

            Text {
                text: Qt.formatDate(Clock.now, "dddd, MMMM d, yyyy")
                font.family: Appearance.font.family.main
                font.pixelSize: Appearance.font.pixelSize.normal
                color: Appearance.colors.text
                Layout.alignment: Qt.AlignLeft
            }
            
            RowLayout {
                Layout.fillWidth: true
                spacing: Appearance.sizes.padding

                Text {
                    text: "Time"
                    font.family: Appearance.font.family.main
                    font.pixelSize: Appearance.font.pixelSize.small
                    color: Appearance.colors.textSecondary
                }
                
                Item { Layout.fillWidth: true }

                Text {
                    text: Qt.formatTime(Clock.now, "hh:mm:ss AP")
                    font.family: Appearance.font.family.main
                    font.pixelSize: Appearance.font.pixelSize.small
                    color: Appearance.colors.text
                }
            }
            
            RowLayout {
                Layout.fillWidth: true
                spacing: Appearance.sizes.padding

                Text {
                    text: "System Uptime"
                    font.family: Appearance.font.family.main
                    font.pixelSize: Appearance.font.pixelSize.small
                    color: Appearance.colors.textSecondary
                }
                
                Item { Layout.fillWidth: true }
                
                Text {
                    text: SystemInfo.uptime
                    font.family: Appearance.font.family.main
                    font.pixelSize: Appearance.font.pixelSize.small
                    color: Appearance.colors.text
                }
            }
        }
    }
}
