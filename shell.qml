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

    // 1. Config Loader
    Process {
        id: configLoader
        // Note: I added a fallback to look in the current folder if the hardcoded path fails
        command: ["cat", Quickshell.env("HOME") + "/.config/quickshell/config.jsonc"]
        running: true
        
        onExited: {
            if (configLoader.exitCode === 0) {
                let content = configLoader.stdout.replace(/\/\*[\s\S]*?\*\/|\/\/.*/g, '')
                try {
                    let parsed = JSON.parse(content)
                    Config.loadConfig(parsed)
                } catch (e) {
                    console.error("Failed to parse config!\n", e)
                }
            }
        }
    }

    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: barWindow
            
            // FIX: This property is required to receive data from Variants
            property var modelData
            property var screenInfo: modelData 
            screen: screenInfo 
            
            // FIX: Use implicitHeight instead of height
            implicitHeight: Config.bar.height || 40

            anchors {
                top: Config.bar.position === "top"
                bottom: Config.bar.position === "bottom"
                left: true
                right: true
            }
             
            margins {
                top: Config.bar.position === "top" ? (Config.bar.margin || 10) : 0
                bottom: Config.bar.position === "bottom" ? (Config.bar.margin || 10) : 0
                left: Config.bar.margin || 10
                right: Config.bar.margin || 10
            }

            Bar {
                anchors.fill: parent
                visible: Config.loaded && Config.bar.enabled
            }
        }
    }

    LazyLoader {
        id: controlCenterLoader
        active: Config.loaded && Config.controlCenter.enabled

        PanelWindow {
            id: controlCenterWindow
            visible: false
            
            // FIX: Use implicit sizes
            implicitWidth: Config.controlCenter.width || 400
            implicitHeight: 600
            
            screen: Quickshell.screens[0]
            
            exclusionMode: ExclusionMode.Ignore 

            anchors {
                right: Config.controlCenter.position === "right"
                left: Config.controlCenter.position === "left"
                top: true
            }
            
            margins {
                top: (Config.bar.height || 40) + (Config.bar.margin || 10) + 20
                right: Config.controlCenter.position === "right" ? 20 : 0
                left: Config.controlCenter.position === "left" ? 20 : 0
            }

            ControlCenter {
                anchors.fill: parent
            }
        }
    }

    LazyLoader {
        id: launcherLoader
        active: Config.loaded && Config.launcher.enabled

        FloatingWindow {
            id: launcherWindow
            visible: false
            
            // FIX: Use implicit sizes
            implicitWidth: Config.launcher.width || 600
            implicitHeight: Config.launcher.height || 500
            
            screen: Quickshell.screens[0]
            
            // Center the window (using implicit sizes)
            // x: (screen.width - implicitWidth) / 2
            // y: (screen.height - implicitHeight) / 2

            AppLauncher {
                anchors.fill: parent
                onLaunchApp: launcherWindow.visible = false
            }
        }
    }

    NotificationPopups {
        visible: Config.loaded && Config.notifications.enabled
    }
}