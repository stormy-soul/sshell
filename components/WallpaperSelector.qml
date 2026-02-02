import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import Qt5Compat.GraphicalEffects
import "../settings"
import "../services"
import "common" as Common

PanelWindow {
    id: root
    
    property bool shown: false
    visible: shown
    
    color: "transparent"
    
    WlrLayershell.namespace: "sshell:wallpaper-selector"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
    WlrLayershell.exclusionMode: ExclusionMode.Ignore
    
    anchors {
        top: true
        left: true
        right: true
    }
    
    margins {
        top: Appearance.sizes.barHeight + (Appearance.sizes.barMargin * 2) // Approximate
        left: (screen.width / 4)
        right: (screen.width / 4)
    }
    
    implicitHeight: 600
    
    mask: Region {
        item: background
    }
    
    HyprlandFocusGrab {
        id: grab
        windows: [root]
        active: root.visible
        onCleared: {
            if (!active) root.shown = false
        }
    }
    
    Rectangle {
        id: background
        anchors.fill: parent
        color: Appearance.colors.overlayBackground
        radius: Appearance.sizes.cornerRadiusLarge
        border.width: 1
        border.color: Appearance.colors.border
        clip: true
        
        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 10
            spacing: 10
            
            Text {
                text: "Select Wallpaper"
                color: Appearance.colors.text
                font.family: Appearance.font.family.main
                font.pixelSize: Appearance.font.pixelSize.huge
                font.weight: Font.DemiBold
                Layout.alignment: Qt.AlignHCenter
            }
            
            GridView {
                id: grid
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true
                
                cellWidth: width / 3
                cellHeight: cellWidth * 0.75
                
                model: WallpaperService.wallpapers
                
                highlight: Rectangle {
                    color: Appearance.colors.surfaceVariant
                    radius: Appearance.sizes.cornerRadiusSmall
                    opacity: 0.5
                }
                highlightFollowsCurrentItem: true
                
                delegate: Item {
                    width: grid.cellWidth
                    height: grid.cellHeight
                    
                    Rectangle {
                        anchors.fill: parent
                        anchors.margins: 5
                        color: "transparent"
                        radius: Appearance.sizes.cornerRadiusSmall
                        border.width: GridView.isCurrentItem ? 2 : 0
                        border.color: Appearance.colors.primary
                        
                        Image {
                            id: thumb
                            anchors.fill: parent
                            anchors.margins: 2
                            source: model.thumb !== "" ? "file://" + model.thumb : "file://" + model.path
                            sourceSize.width: 400 
                            sourceSize.height: 400
                            fillMode: Image.PreserveAspectCrop
                            asynchronous: true
                            cache: true
                            smooth: true
                            
                            layer.enabled: true
                            layer.effect: OpacityMask {
                                maskSource: Rectangle {
                                    width: thumb.width
                                    height: thumb.height
                                    radius: Appearance.sizes.cornerRadius - 2
                                    visible: false
                                }
                            }
                        }
                        
                        Rectangle {
                            anchors.bottom: parent.bottom
                            anchors.left: parent.left
                            anchors.right: parent.right
                            height: 30
                            color: Qt.rgba(0,0,0,0.6)
                            radius: parent.radius
                             
                            Text {
                                anchors.centerIn: parent
                                text: model.name
                                color: Appearance.colors.textSecondary
                                font.family: Appearance.font.family.main
                                font.pixelSize: Appearance.font.pixelSize.small
                                elide: Text.ElideMiddle
                                width: parent.width - 10
                                horizontalAlignment: Text.AlignHCenter
                            }
                        }
                        
                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                grid.currentIndex = index
                                WallpaperService.setWallpaper(model.path)
                                root.shown = false
                            }
                        }
                    }
                }
                
                focus: true
                Keys.onPressed: (event) => {
                    if (event.key === Qt.Key_Escape) {
                        root.shown = false
                    } else if (event.key === Qt.Key_Enter || event.key === Qt.Key_Return) {
                        WallpaperService.setWallpaper(model.get(currentIndex).path)
                        root.shown = false
                    }
                }
            }
        }
    }
}
