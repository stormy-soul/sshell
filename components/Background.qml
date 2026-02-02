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

    Image {
        id: wallpaper
        anchors.fill: parent
        source: WallpaperService.currentWallpaper && WallpaperService.currentWallpaper !== "" ? "file://" + WallpaperService.currentWallpaper : ""
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
