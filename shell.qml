//@ pragma UseQApplication
import Quickshell
import Quickshell.Io
import QtQuick
import Quickshell.Hyprland
import Quickshell.Wayland

import "./settings"
import "./services"
import "./components/bar"
import "./components/controlcenter"
import "./components/launcher"
import "./components/launcher"
import "./components/notifications"
import "./components/session"
import "./components"
import "./components/common" as Common

ShellRoot {
    id: root

    property var osdMonitor: OSDMonitor 

    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: barWindow
            property var modelData
            property var screenInfo: modelData 
            screen: screenInfo 

            WlrLayershell.namespace: "sshell:bar"
            implicitHeight: Config.bar.height
            color: "transparent"

            anchors {
                top: Config.bar.position === "top"
                bottom: Config.bar.position === "bottom"
                left: true
                right: true
            }
             
            margins {
                top: Config.bar.position === "top" ? Config.bar.margin : 0
                bottom: Config.bar.position === "bottom" ? Config.bar.margin : 0
                left: Config.bar.margin
                right: Config.bar.margin
            }

            Bar {
                id: bar
                anchors.fill: parent
                visible: Config.ready && Config.bar.enabled
                opacity: ShellState.masterVisible ? 1 : 0
            }
            
            mask: Region {
                item: ShellState.masterVisible ? bar : null
            }
        }
    }

    LazyLoader {
        id: controlCenterLoader
        active: Config.ready && Config.controlCenter.enabled

        PanelWindow {
            id: controlCenterWindow
            visible: ModuleLoader.controlCenterVisible
            color: "transparent"
            
            WlrLayershell.namespace: "sshell:control-center"
            WlrLayershell.layer: WlrLayer.Overlay
            
            screen: Quickshell.screens[0]
            
            anchors {
                top: true
                bottom: true
                left: true
                right: true
            }
            
            mask: Region {
                item: (ModuleLoader.controlCenterVisible && ShellState.masterVisible) ? controlCenterItem : null
            }
            
            HyprlandFocusGrab {
                id: ccFocusGrab
                windows: [controlCenterWindow]
                active: ModuleLoader.controlCenterVisible
                
                onCleared: {
                    if (!active) ModuleLoader.controlCenterVisible = false
                }
            }

            ControlCenter {
                id: controlCenterItem
                opacity: ShellState.masterVisible ? 1 : 0
                focus: true
                
                width: Config.controlCenter.width
                height: parent.height - (Config.bar.height + Config.bar.margin)
                
                anchors.top: parent.top
                anchors.topMargin: Config.bar.margin
                
                anchors.right: Config.controlCenter.position === "right" ? parent.right : undefined
                anchors.left: Config.controlCenter.position === "left" ? parent.left : undefined
                
                anchors.rightMargin: Config.controlCenter.position === "right" ? (Config.bar.padding * 2) : 0
                anchors.leftMargin: Config.controlCenter.position === "left" ? (Config.bar.padding * 2) : 0
                
                Keys.onEscapePressed: ModuleLoader.controlCenterVisible = false
                
                onRequestSessionScreen: {
                    ModuleLoader.controlCenterVisible = false
                    sessionScreen.toggle()
                }
            }
        }
    }

    PanelWindow {
        id: launcherWindow
        visible: ModuleLoader.launcherVisible
        color: "transparent"
        
        screen: Quickshell.screens[0]
        
        WlrLayershell.namespace: "sshell:launcher"
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
        
        anchors {
            top: true
            bottom: true
            left: true
            right: true
        }
        
        mask: Region {
            item: (ModuleLoader.launcherVisible && ShellState.masterVisible) ? appLauncher : null
        }
        
        HyprlandFocusGrab {
            id: focusGrab
            windows: [launcherWindow]
            active: false
            
            onCleared: {
                if (!active) {
                    ModuleLoader.launcherVisible = false
                }
            }
        }
        
        Timer {
            id: delayedGrabTimer
            interval: 50
            repeat: false
            onTriggered: {
                focusGrab.active = ModuleLoader.launcherVisible
            }
        }
        
        Connections {
            target: ModuleLoader
            function onLauncherVisibleChanged() {
                if (ModuleLoader.launcherVisible) {
                    LauncherSearch.query = ""
                    delayedGrabTimer.start()
                    Qt.callLater(function() {
                        appLauncher.focusSearchInput()
                    })
                } else {
                    focusGrab.active = false
                    LauncherSearch.query = ""
                }
            }
        }
        
        AppLauncher {
            id: appLauncher
            opacity: ShellState.masterVisible ? 1 : 0
            anchors.fill: parent
            
            Keys.onEscapePressed: {
                if (LauncherSearch.query !== "") {
                    LauncherSearch.query = ""
                } else {
                    ModuleLoader.launcherVisible = false
                }
            }
        }
    }

    NotificationPopups {
        visible: Config.ready && Config.notifications.enabled
    }
    
    PanelWindow {
        id: osdWindow
        visible: OSD.visible && Config.osd?.enabled !== false
        color: "transparent"
        
        screen: Quickshell.screens[0]
        
        WlrLayershell.namespace: "sshell:osd"
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
        
        exclusionMode: ExclusionMode.Ignore
        
        anchors {
            top: true
            left: true
            right: true
        }
        
        implicitHeight: osdPopup.y + osdPopup.height + 10
        
        mask: Region {
            item: (OSD.visible && ShellState.masterVisible) ? osdPopup : null
        }
        
        Common.OSD {
            id: osdPopup
            opacity: ShellState.masterVisible ? 1 : 0
            anchors.horizontalCenter: parent.horizontalCenter
            y: Appearance.sizes.barHeight + Appearance.sizes.barMargin + 10
        }
    }
    
    Variants {
        model: Quickshell.screens
        Background {
            screen: modelData
        }
    }
    
    WallpaperSelector {
        id: wallpaperSelector
        screen: Quickshell.screens[0]
        shown: false
    }

    Settings {
        id: settingsWindow
        screen: Quickshell.screens[0]
        shown: false
    }
    
    SessionScreen {
        id: sessionScreen
        screen: Quickshell.screens[0]
    }
    
    GlobalShortcut {
        name: "launcherToggle"
        description: "Toggle app launcher"
        onPressed: ModuleLoader.toggleLauncher()
    }
    
    GlobalShortcut {
        name: "controlCenterToggle"
        description: "Toggle control center"
        onPressed: ModuleLoader.toggleControlCenter()
    }
    
    GlobalShortcut {
        name: "clipboardToggle"
        description: "Toggle clipboard history"
        onPressed: ModuleLoader.toggleClipboard()
    }
    
    GlobalShortcut {
        name: "testNotification"
        description: "Send a test notification"
        onPressed: NotificationService.sendTestNotification()
    }

    GlobalShortcut {
        name: "brightnessUp"
        description: "Increase Brightness"
        onPressed: {
            Brightness.change(0.05)
        }
    }

    GlobalShortcut {
        name: "brightnessDown"
        description: "Decrease Brightness"
        onPressed: {
            Brightness.change(-0.05)
        }
    }
    
    GlobalShortcut {
        name: "audioVolumeUp"
        description: "Increase Volume"
        onPressed: Audio.incrementVolume()
    }

    GlobalShortcut {
        name: "audioVolumeDown"
        description: "Decrease Volume"
        onPressed: Audio.decrementVolume()
    }
    
    GlobalShortcut {
        name: "audioMute"
        description: "Toggle Mute"
        onPressed: Audio.toggleMute()
    }

    GlobalShortcut {
        name: "shellStateToggle"
        description: "Toggle Shell State"
        onPressed: ShellState.toggle()
    }

    GlobalShortcut {
        name: "wallpaperSelectorToggle"
        description: "Toggle Wallpaper Selector"
        onPressed: wallpaperSelector.shown = !wallpaperSelector.shown
    }

    GlobalShortcut {
        name: "backgroundToggle"
        description: "Toggle Wallpaper Visibility"
        onPressed: WallpaperService.toggleVisible()
    }

    GlobalShortcut {
        name: "settingsToggle"
        description: "Toggle Settings Window"
        onPressed: settingsWindow.shown = !settingsWindow.shown
    }
    
    GlobalShortcut {
        name: "sessionToggle"
        description: "Toggle session screen"
        onPressed: sessionScreen.toggle()
    }
}