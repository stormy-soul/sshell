import Quickshell
import Quickshell.Io
import QtQuick

ShellRoot {
    id: root

    Process {
        id: configLoader
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

    Singleton {
        id: _Config

        property var bar: ({})
        property var controlCenter: ({})
        property var notifications: ({})
        property var launcher: ({})
        property var theme: ({})
        property bool loaded: false

        function loadConfig(config) {
            bar = config.bar || {}
            controlCenter = config.controlCenter || {}
            notifications = config.notifications || {}
            launcher = config.launcher || {}
            theme = config.theme || {}
            loaded = true
        }
    }

    // Bar windows
    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: barWindow
            property var screenInfo: modelData
            screen: modelData
            height: Config.bar.height || 40

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

    // Control Center
    LazyLoader {
        id: controlCenterLoader
        active: Config.loaded && Config.controlCenter.enabled

        FloatingWindow {
            id: controlCenterWindow
            visible: false
            width: Config.controlCenter.width || 400
            height: 600
            screen: Quickshell.screens[0]

            anchor {
                right: Config.controlCenter.position === "right"
                left: Config.controlCenter.position === "left"
                top: true

                adjustment {
                    x: Config.controlCenter.position === "right" ? -20 : 20
                    y: (Config.bar.height || 40) + (Config.bar.margin || 10) + 20
                }
            }

            ControlCenter {
                anchors.fill: parent
            }
        }
    }

    // App Launcher
    LazyLoader {
        id: launcherLoader
        active: Config.loaded && Config.launcher.enabled

        FloatingWindow {
            id: launcherWindow
            visible: false
            width: Config.launcher.width || 600
            height: Config.launcher.height || 500
            screen: Quickshell.screens[0]

            anchor {
                horizontalCenter: true
                verticalCenter: true
            }

            AppLauncher {
                anchors.fill: parent
                onLaunchApp: launcherWindow.visible = false
            }
        }
    }

    // Notifications
    NotificationPopups {
        visible: Config.loaded && Config.notifications.enabled
    }
}