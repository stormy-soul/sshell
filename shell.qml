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
import "./components/notifications"

ShellRoot {
    id: root

    // Bar windows
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
                anchors.fill: parent
                visible: Config.ready && Config.bar.enabled
            }
        }
    }

    // Control Center
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
                item: ModuleLoader.controlCenterVisible ? controlCenterItem : null
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
                focus: true // Receive keys
                
                width: Config.controlCenter.width
                height: parent.height - (Config.bar.height + Config.bar.margin)
                
                anchors.top: parent.top
                anchors.topMargin: Config.bar.margin
                
                anchors.right: Config.controlCenter.position === "right" ? parent.right : undefined
                anchors.left: Config.controlCenter.position === "left" ? parent.left : undefined
                
                anchors.rightMargin: Config.controlCenter.position === "right" ? (Config.bar.padding * 2) : 0
                anchors.leftMargin: Config.controlCenter.position === "left" ? (Config.bar.padding * 2) : 0
                
                Keys.onEscapePressed: ModuleLoader.controlCenterVisible = false
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
        
        anchors {
            top: true
            bottom: true
            left: true
            right: true
        }
        
        mask: Region {
            item: ModuleLoader.launcherVisible ? appLauncher : null
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
                    // Focus the input
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

    // Notifications
    NotificationPopups {
        visible: Config.ready && Config.notifications.enabled
    }
}