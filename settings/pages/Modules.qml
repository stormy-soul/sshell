import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import "../../components/settings"
import "../../components/common"
import "../"

ContentPage {
    id: root
    property int gap: 15

    ContentSection {
        title: "Workspaces"
        icon: "workspaces"
        
        ContentSubsection {
            title: "Persistent Workspaces"
            Rectangle {
                Layout.preferredWidth: styleArray.implicitWidth
                Layout.preferredHeight: 30
                color: Appearance.colors.surfaceVariant
                radius: Appearance.sizes.cornerRadius
                StyledTextInput {
                    anchors.fill: parent
                    anchors.margins: 4
                    text: Config.workspaces.persistent.toString()
                    onTextEdited: { }
                }
            }
        }

        ContentSubsection {
            title: "Style"
            ConfigSelectionArray {
                id: styleArray
                options: [
                    { displayName: "Arabic", value: "arabic" },
                    { displayName: "Roman", value: "roman" },
                    { displayName: "Han", value: "han" },
                    { displayName: "Dot", value: "dot" }
                ]
                currentValue: Config.workspaces.style
                onSelected: (val) => Config.workspaces.style = val
            }
        }

        ContentSubsection {
            title: "Radius"
            ConfigSelectionArray {
                options: [
                    { displayName: "Circle", value: "circle" },
                    { displayName: "Rounded", value: "rounded" },
                    { displayName: "Sharp", value: "sharp" }
                ]
                currentValue: Config.workspaces.radius
                onSelected: (val) => Config.workspaces.radius = val
            }
        }
    }

    ContentSection {
        title: "Clock"
        icon: "schedule"
        space: root.gap
        
        ContentSubsection {
            title: "Format"
            ConfigSelectionArray {
                options: [
                    { displayName: "12-hour", value: "12" },
                    { displayName: "24-hour", value: "24" }
                ]
                currentValue: Config.clock.format
                onSelected: (val) => Config.clock.format = val
            }
        }

        ContentSubsection {
            ToggleButton {
                title: "Show Date"
                subtitle: "Shows the date in the clock"
                hasIcon: false
                checked: Config.clock.showDate
                onClicked: Config.clock.showDate = !Config.clock.showDate
            }
        }
    }

    ContentSection {
        title: "Weather"
        icon: "wb_sunny"
        space: root.gap
        
        ContentSubsection {
            title: "Interval(ms)"
            Rectangle {
                Layout.preferredWidth: 100
                Layout.preferredHeight: 30
                color: Appearance.colors.surfaceVariant
                radius: Appearance.sizes.cornerRadius
                StyledTextInput {
                    anchors.fill: parent; anchors.margins: 4; text: Config.weather.interval.toString()
                    onTextEdited: { var val = parseInt(text); if(!isNaN(val)) Config.weather.interval = val; }
                }
            }
        }

        ContentSubsection {
            title: "Unit"
            ConfigSelectionArray {
                id: unitArray
                options: [
                    { displayName: "Metric", value: "metric" },
                    { displayName: "Imperial", value: "imperial" }
                ]
                currentValue: Config.weather.unit
                onSelected: (val) => Config.weather.unit = val
            }
        }

        ContentSubsection {
            title: "City"
            Rectangle {
                Layout.preferredWidth: unitArray.implicitWidth
                Layout.preferredHeight: 30
                color: Appearance.colors.surfaceVariant
                radius: Appearance.sizes.cornerRadius
                StyledTextInput {
                    anchors.fill: parent; anchors.margins: 4; text: Config.weather.city
                    onTextEdited: { Config.weather.city = text; }
                }
            }
        }

        ContentSubsection {
            ToggleButton {
                title: "Use Geolocation"
                subtitle: "Uses Geolocation to get the current location"
                hasIcon: false
                checked: Config.weather.useGPS
                onClicked: Config.weather.useGPS = !Config.weather.useGPS
            }
        }

        ContentSubsection {
            ToggleButton {
                title: "Use USCS"
                subtitle: "Uses USCS(Fahrenheit) for current temperature"
                hasIcon: false
                checked: Config.weather.useUSCS
                onClicked: Config.weather.useUSCS = !Config.weather.useUSCS
            }
        }
        ContentSubsection {
            ToggleButton {
                title: "Hide Location"
                subtitle: "Hides the location text in the popup"
                hasIcon: false
                checked: Config.weather.hideLocation
                onClicked: Config.weather.hideLocation = !Config.weather.hideLocation
            }
        }
    }

    ContentSection {
        title: "Tray"
        icon: "view_list"
        space: root.gap
        
        ContentSubsection {
            ToggleButton {
                title: "Show Network Name"
                subtitle: "Shows the network ssid in the tray"
                hasIcon: false
                checked: Config.tray.showNetworkName
                onClicked: Config.tray.showNetworkName = !Config.tray.showNetworkName
            }
        }

        ContentSubsection {
            ToggleButton {
                title: "Show Bluetooth Name"
                subtitle: "Shows the device name in the tray"
                hasIcon: false
                checked: Config.tray.showBluetoothName
                onClicked: Config.tray.showBluetoothName = !Config.tray.showBluetoothName
            }
        }
    }

    ContentSection {
        title: "MPRIS"
        icon: "music_note"
        space: root.gap
        
        ContentSubsection {
            ToggleButton {
                title: "Bar Visualizer"
                subtitle: "Shows the visualizer in the bar"
                hasIcon: false
                checked: Config.mpris.barVisualizer
                onClicked: Config.mpris.barVisualizer = !Config.mpris.barVisualizer
            }
        }

        ContentSubsection {
            ToggleButton {
                title: "Show Artist"
                subtitle: "Shows the artist in the bar"
                hasIcon: false
                checked: Config.mpris.showArtist
                onClicked: Config.mpris.showArtist = !Config.mpris.showArtist
            }
        }

        ContentSubsection {
            ToggleButton {
                title: "Popup Visualizer"
                subtitle: "Shows the visualizer in the popup"
                hasIcon: false
                checked: Config.mpris.popupVisualizer
                onClicked: Config.mpris.popupVisualizer = !Config.mpris.popupVisualizer
            }
        }

        ContentSubsection {
            ToggleButton {
                title: "Hide On Paused"
                subtitle: "Hides the module when the track is paused"
                hasIcon: false
                checked: Config.mpris.hideOnPause
                onClicked: Config.mpris.hideOnPause = !Config.mpris.hideOnPause
            }
        }

        ContentSubsection {
            title: "Ignored Players"
            Rectangle {
                Layout.preferredWidth: 100
                Layout.preferredHeight: 30
                color: Appearance.colors.surfaceVariant
                radius: Appearance.sizes.cornerRadius
                StyledTextInput {
                    anchors.fill: parent; anchors.margins: 4; text: Config.mpris.ignoredPlayers
                    onTextEdited: { Config.mpris.ignoredPlayers = text; }
                }
            }
        }

        ContentSubsection {
            title: "Max Width"
            Rectangle {
                Layout.preferredWidth: 100
                Layout.preferredHeight: 30
                color: Appearance.colors.surfaceVariant
                radius: Appearance.sizes.cornerRadius
                StyledTextInput {
                    anchors.fill: parent; anchors.margins: 4; text: Config.mpris.maxWidthOnBar
                    onTextEdited: { var val = parseInt(text); if(!isNaN(val)) Config.mpris.maxWidthOnBar = Math.max(400, Math.min(val, 1000)); }
                }
            }
        }  
    }

    ContentSection {
        title: "Launcher"
        icon: "apps"
        space: root.gap
        
        ContentSubsection {
            ToggleButton {
                title: "Show Launcher"
                subtitle: "Shows the launcher icon in the bar"
                hasIcon: false
                checked: Config.launcher.enabled
                onClicked: Config.launcher.enabled = !Config.launcher.enabled
            }
        }

        ContentSubsection {
            title: "Launcher Width"
            Rectangle {
                Layout.preferredWidth: 100
                Layout.preferredHeight: 30
                color: Appearance.colors.surfaceVariant
                radius: Appearance.sizes.cornerRadius
                StyledTextInput {
                    anchors.fill: parent; anchors.margins: 4; text: Config.launcher.width
                    onTextEdited: { var val = parseInt(text); if(!isNaN(val)) Config.launcher.searchBarWidth = Math.max(400, Math.min(val, 1000)); }
                }
            }
        }  

        ContentSubsection {
            title: "Launcher Height"
            Rectangle {
                Layout.preferredWidth: 100
                Layout.preferredHeight: 30
                color: Appearance.colors.surfaceVariant
                radius: Appearance.sizes.cornerRadius
                StyledTextInput {
                    anchors.fill: parent; anchors.margins: 4; text: Config.launcher.height
                    onTextEdited: { var val = parseInt(text); if(!isNaN(val)) Config.launcher.searchBarHeight = Math.max(500, Math.min(val, 1000)); }
                }
            }
        }        
    }
}