import QtQuick
import Quickshell
import Quickshell.Wayland
import "../services"
import "../settings"
import "procedural"

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

    readonly property bool isShaderMode: Config.background.wallpaperMode === "shader"
    readonly property bool isGif: !isShaderMode && WallpaperService.currentWallpaper.toLowerCase().endsWith(".gif")

    // Background visibility toggle
    Item {
        id: bgContent
        anchors.fill: parent
        visible: WallpaperService.backgroundVisible
        opacity: visible ? 1 : 0
        
        Behavior on opacity {
            NumberAnimation { duration: Appearance.animation.durationSlow }
        }

        Loader {
            id: wallpaperLoader
            anchors.fill: parent
            active: !root.isShaderMode
            
            sourceComponent: root.isGif ? animatedWallpaper : staticWallpaper
            
            property string wallpaperSource: WallpaperService.currentWallpaper && WallpaperService.currentWallpaper !== "" ? "file://" + WallpaperService.currentWallpaper : ""
        }
        
        Loader {
            id: shaderLoader
            anchors.fill: parent
            active: root.isShaderMode
            
            sourceComponent: Component {
                ProceduralSky {}
            }
        }
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
    
    // Capture the entire background content for wallpaper persistence (shader mode)
    Connections {
        target: WallpaperService
        function onCaptureBackground(destPath) {
            bgContent.grabToImage(function(result) {
                if (result) {
                    result.saveToFile(destPath)
                    console.log("Background: Captured to", destPath)
                } else {
                    console.error("Background: grabToImage failed")
                }
            })
        }
    }
}
