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
            
            implicitHeight: Config.options.bar.height
            color: "transparent"

            anchors {
                top: Config.options.bar.position === "top"
                bottom: Config.options.bar.position === "bottom"
                left: true
                right: true
            }
             
            margins {
                top: Config.options.bar.position === "top" ? Config.options.bar.margin : 0
                bottom: Config.options.bar.position === "bottom" ? Config.options.bar.margin : 0
                left: Config.options.bar.margin
                right: Config.options.bar.margin
            }

            Bar {
                anchors.fill: parent
                visible: Config.ready && Config.options.bar.enabled
            }
        }
    }

    // Control Center
    LazyLoader {
        id: controlCenterLoader
        active: Config.ready && Config.options.controlCenter.enabled

        PanelWindow {
            id: controlCenterWindow
            visible: false
            
            implicitWidth: Config.options.controlCenter.width
            implicitHeight: 600
            
            screen: Quickshell.screens[0]
            
            exclusionMode: ExclusionMode.Ignore 

            anchors {
                right: Config.options.controlCenter.position === "right"
                left: Config.options.controlCenter.position === "left"
                top: true
            }
            
            margins {
                top: Config.options.bar.height + Config.options.bar.margin + 20
                right: Config.options.controlCenter.position === "right" ? 20 : 0
                left: Config.options.controlCenter.position === "left" ? 20 : 0
            }

            ControlCenter {
                anchors.fill: parent
            }
        }
    }

    // App Launcher
    LazyLoader {
        id: launcherLoader
        active: Config.ready && Config.options.launcher.enabled

        FloatingWindow {
            id: launcherWindow
            visible: false
            
            implicitWidth: Config.options.launcher.width
            implicitHeight: Config.options.launcher.height
            
            screen: Quickshell.screens[0]

            AppLauncher {
                anchors.fill: parent
                onLaunchApp: launcherWindow.visible = false
            }
        }
    }

    // Notifications
    NotificationPopups {
        visible: Config.ready && Config.options.notifications.enabled
    }
}