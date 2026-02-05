import QtQuick
import Quickshell
import Quickshell.Wayland
import "../services"
import "../settings"

PanelWindow {
    id: root

    WlrLayershell.namespace: "sshell:background"
    WlrLayershell.layer: WlrLayer.Background
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
    exclusionMode: ExclusionMode.Ignore
    
    property var modelData
    screen: modelData
    
    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }

    color: "black"

    readonly property bool isGif: WallpaperService.currentWallpaper.toLowerCase().endsWith(".gif")

    Loader {
        id: wallpaperLoader
        anchors.fill: parent
        
        sourceComponent: root.isGif ? animatedWallpaper : staticWallpaper
        
        property string wallpaperSource: WallpaperService.currentWallpaper && WallpaperService.currentWallpaper !== "" ? "file://" + WallpaperService.currentWallpaper : ""
    }
    
    Component {
        id: staticWallpaper
        
        Image {
            id: wallpaper
            source: wallpaperLoader.wallpaperSource
            fillMode: Image.PreserveAspectCrop
            asynchronous: true
            smooth: true
            mipmap: true
            
            Behavior on source {
                SequentialAnimation {
                    NumberAnimation { target: wallpaper; property: "opacity"; to: 0; duration: 200 }
                    PropertyAction { target: wallpaper; property: "source" }
                    NumberAnimation { target: wallpaper; property: "opacity"; to: 1; duration: 500 }
                }
            }
        }
    }
    
    Component {
        id: animatedWallpaper
        
        AnimatedImage {
            id: animWallpaper
            source: wallpaperLoader.wallpaperSource
            fillMode: Image.PreserveAspectCrop
            asynchronous: true
            smooth: true
            playing: true
            
            Behavior on source {
                SequentialAnimation {
                    NumberAnimation { target: animWallpaper; property: "opacity"; to: 0; duration: 200 }
                    PropertyAction { target: animWallpaper; property: "source" }
                    NumberAnimation { target: animWallpaper; property: "opacity"; to: 1; duration: 500 }
                }
            }
        }
    }
}
