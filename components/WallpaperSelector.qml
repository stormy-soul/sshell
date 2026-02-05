import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import "../settings"
import "../services"
import "common" as Common
import Qt5Compat.GraphicalEffects

PanelWindow {
    id: root
    
    property bool shown: false
    visible: shown
    
    color: "transparent"
    
    WlrLayershell.namespace: "sshell:wallpaper-selector"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
    exclusionMode: ExclusionMode.Ignore
    
    anchors {
        top: true
        left: true
        right: true
    }
    
    margins {
        top: Appearance.sizes.barHeight + (Appearance.sizes.barMargin * 2)
        left: screen.width / 4
        right: screen.width / 4
    }
    
    implicitHeight: 600
    
    mask: Region { item: background }
    
    property var selectedExtensions: []
    property var filteredWallpapers: {
        var total = WallpaperService.wallpapers.count
        var filtered = []
        for (var i = 0; i < total; i++) {
            var item = WallpaperService.wallpapers.get(i)
            if (selectedExtensions.length === 0 || selectedExtensions.includes(item.extension)) {
                filtered.push(item)
            }
        }
        return filtered
    }
    
    function toggleExtension(ext) {
        var index = selectedExtensions.indexOf(ext)
        if (index > -1) {
            var temp = selectedExtensions.slice()
            temp.splice(index, 1)
            selectedExtensions = temp
        } else {
            selectedExtensions = selectedExtensions.concat([ext])
        }
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
        border.color: Qt.rgba(Appearance.colors.border.r, Appearance.colors.border.g, Appearance.colors.border.b, 0.1)
        clip: true
        
        ColumnLayout {
            anchors.fill: parent
            anchors.margins: Appearance.sizes.paddingLarge
            spacing: Appearance.sizes.padding
            
            Text {
                text: "Select Wallpaper"
                color: Appearance.colors.text
                font.family: Appearance.font.family.main
                font.pixelSize: Appearance.font.pixelSize.huge
                font.weight: Font.DemiBold
                Layout.alignment: Qt.AlignLeft
            }
            
            Text {
                text: {
                    var total = WallpaperService.wallpapers.count
                    var shown = root.filteredWallpapers.length !== undefined ? 
                                root.filteredWallpapers.length : total
                    
                    if (root.selectedExtensions.length === 0) {
                        return `Showing all ${total} wallpapers`
                    }
                    return `Showing ${shown} of ${total} wallpapers`
                }
                color: Appearance.colors.textSecondary
                font.family: Appearance.font.family.main
                font.pixelSize: Appearance.font.pixelSize.small
                Layout.alignment: Qt.AlignLeft
            }
            
            Flow {
                Layout.fillWidth: true
                spacing: Appearance.sizes.paddingSmall
                
                Repeater {
                    model: WallpaperService.extensions
                    
                    Rectangle {
                        id: chip
                        
                        readonly property string ext: modelData
                        readonly property bool isSelected: root.selectedExtensions.includes(ext)
                        
                        width: chipRow.width + Appearance.sizes.padding * 4 
                        height: 32
                        radius: Appearance.sizes.cornerRadiusSmall
                        color: isSelected ? Appearance.colors.accent : Appearance.colors.overlayBackground
                        
                        Behavior on color {
                            ColorAnimation { duration: Appearance.animation.duration }
                        }
                        
                        Row {
                            id: chipRow
                            anchors.centerIn: parent
                            spacing: Appearance.sizes.paddingSmall
                            
                            MaterialIcon {
                                icon: chip.isSelected ? "check" : getExtensionIcon(chip.ext)
                                color: chip.isSelected ? Appearance.colors.colOnPrimary : Appearance.colors.text
                                width: Appearance.font.pixelSize.large
                                height: Appearance.font.pixelSize.large
                                anchors.verticalCenter: parent.verticalCenter
                                
                                Behavior on color {
                                    ColorAnimation { duration: Appearance.animation.durationFast }
                                }
                            }
                            
                            Text {
                                text: chip.ext.toUpperCase()
                                color: chip.isSelected ? Appearance.colors.colOnPrimary : Appearance.colors.text
                                font.family: Appearance.font.family.main
                                font.pixelSize: Appearance.font.pixelSize.small
                                font.weight: Font.Medium
                                verticalAlignment: Text.AlignVCenter
                                
                                Behavior on color {
                                    ColorAnimation { duration: Appearance.animation.duration }
                                }
                            }
                        }
                        
                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.toggleExtension(chip.ext)
                        }
                    }
                }
            }
            
            GridView {
                id: grid
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true
                
                cellWidth: width / 3
                cellHeight: cellWidth * 0.75
                
                model: root.filteredWallpapers
                
                highlight: Rectangle {
                    color: Appearance.colors.surfaceVariant
                    radius: Appearance.sizes.cornerRadiusSmall
                    opacity: 0.8
                }
                highlightFollowsCurrentItem: true
                
                delegate: Item {
                    width: grid.cellWidth
                    height: grid.cellHeight
                    
                    required property var modelData
                    
                    Rectangle {
                        anchors.fill: parent
                        anchors.margins: Appearance.sizes.paddingSmall
                        color: "transparent"
                        radius: Appearance.sizes.cornerRadiusSmall
                        border.width: GridView.isCurrentItem ? 2 : 0
                        border.color: Appearance.colors.primary
                        
                        Loader {
                            id: imageLoader
                            anchors.fill: parent
                            anchors.margins: 2
                            
                            sourceComponent: parent.parent.modelData.extension === "gif" ? animatedImageComponent : staticImageComponent
                            
                            property string imagePath: parent.parent.modelData.thumb !== "" ? parent.parent.modelData.thumb : parent.parent.modelData.path
                            
                            layer.enabled: true
                            layer.effect: OpacityMask {
                                maskSource: Rectangle {
                                    width: imageLoader.width
                                    height: imageLoader.height
                                    radius: Appearance.sizes.cornerRadiusSmall
                                    visible: false
                                }
                            }
                        }
                        
                        Rectangle {
                            anchors.top: parent.top
                            anchors.right: parent.right
                            anchors.margins: Appearance.sizes.padding
                            width: extText.width + Appearance.sizes.padding * 2
                            height: 20
                            radius: Appearance.sizes.cornerRadiusSmall
                            color: Appearance.colors.overlayBackground
                            
                            Text {
                                id: extText
                                anchors.centerIn: parent
                                text: parent.parent.parent.modelData.extension.toUpperCase()
                                color: Appearance.colors.text
                                font.family: Appearance.font.family.main
                                font.pixelSize: Appearance.font.pixelSize.tiny
                                font.weight: Font.Bold
                            }
                        }
                        
                        Rectangle {
                            anchors.bottom: parent.bottom
                            anchors.left: parent.left
                            anchors.right: parent.right
                            height: 30
                            color: Qt.rgba(0, 0, 0, 0.6)
                            radius: parent.radius
                             
                            Text {
                                anchors.centerIn: parent
                                text: parent.parent.parent.modelData.name
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
                                WallpaperService.setWallpaper(parent.parent.modelData.path)
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
                        if (currentItem) {
                            WallpaperService.setWallpaper(currentItem.modelData.path)
                            root.shown = false
                        }
                    }
                }
            }
        }
    }
    
    Component {
        id: staticImageComponent
        
        Image {
            source: parent.imagePath !== "" ? "file://" + parent.imagePath : ""
            sourceSize.width: 400
            sourceSize.height: 400
            anchors.fill: parent
            fillMode: Image.PreserveAspectCrop
            asynchronous: true
            cache: true
            smooth: true
        }
    }
    
    Component {
        id: animatedImageComponent
        
        AnimatedImage {
            source: parent.imagePath !== "" ? "file://" + parent.imagePath : ""
            anchors.fill: parent
            fillMode: Image.PreserveAspectCrop
            asynchronous: true
            cache: true
            smooth: true
            playing: true
        }
    }
    
    function getExtensionIcon(ext) {
        switch(ext) {
            case "gif": return "movie"
            case "jpg":
            case "jpeg": return "image"
            case "png": return "palette"
            case "webp": return "public"
            default: return "folder"
        }
    }
}