import Quickshell
import Quickshell.Io
import QtQuick

import "./theme"
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

    // App Launcher
    LazyLoader {
        id: launcherLoader
        active: Config.ready && Config.launcher.enabled

        FloatingWindow {
            id: launcherWindow
            visible: Config.launcherVisible
            
            implicitWidth: Config.launcher.width
            implicitHeight: Config.launcher.height
            
            screen: Quickshell.screens[0]

            AppLauncher {
                anchors.fill: parent
                onLaunchApp: launcherWindow.visible = false
            }
        }
    }

    // Notifications
    NotificationPopups {
        visible: Config.ready && Config.notifications.enabled
    }
}