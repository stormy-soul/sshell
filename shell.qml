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
            visible: false
            
            implicitWidth: Config.controlCenter.width
            implicitHeight: 600
            
            screen: Quickshell.screens[0]
            
            exclusionMode: ExclusionMode.Ignore 

            anchors {
                right: Config.controlCenter.position === "right"
                left: Config.controlCenter.position === "left"
                top: true
            }
            
            margins {
                top: Config.bar.height + Config.bar.margin + 20
                right: Config.controlCenter.position === "right" ? 20 : 0
                left: Config.controlCenter.position === "left" ? 20 : 0
            }

            ControlCenter {
                anchors.fill: parent
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