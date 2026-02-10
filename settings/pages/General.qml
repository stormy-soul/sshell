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
        title: "Theme"
        icon: "palette"
        
        ContentSubsection {
            title: "Icons"
            ConfigSelectionArray {
                options: [
                    { displayName: "Filled", value: "filled" },
                    { displayName: "Outlined", value: "outlined" },
                    { displayName: "Round", value: "round" },
                    { displayName: "Sharp", value: "sharp" },
                    { displayName: "Two-Tone", value: "two-tone" }
                ]
                currentValue: Config.theme.icons
                onSelected: (val) => Config.theme.icons = val
            }
        }
        
        ContentSubsection {
            ToggleButton {
                title: "Colorize Terminal"
                subtitle: "Generate colors for the terminal"
                hasIcon: false
                checked: Config.theme.colorizeTerminal
                onClicked: Config.theme.colorizeTerminal = !Config.theme.colorizeTerminal
            }
        }
        ContentSubsection {
            ToggleButton {
                title: "Dark Mode"
                subtitle: "Toggle dark mode"
                hasIcon: false
                checked: Config.theme.darkmode
                onClicked: Config.theme.darkmode = !Config.theme.darkmode
            }
        }

        ContentSubsection {
            title: "Fonts"
            RowLayout {
                spacing: 20
                Rectangle {
                    Layout.preferredWidth: 300
                    Layout.preferredHeight: 30
                    color: Appearance.colors.surfaceVariant
                    radius: Appearance.sizes.cornerRadius
                    StyledTextInput {
                        anchors.fill: parent; anchors.margins: 4; text: Config.theme.mainFont
                        onTextEdited: { Config.theme.mainFont = text; }
                    }
                }
                Text { text: "Main Font"; color: Appearance.colors.textSecondary; font.family: Appearance.font.family.main }
            }
            RowLayout {
                spacing: 20
                Rectangle {
                    Layout.preferredWidth: 300
                    Layout.preferredHeight: 30
                    color: Appearance.colors.surfaceVariant
                    radius: Appearance.sizes.cornerRadius
                    StyledTextInput {
                        anchors.fill: parent; anchors.margins: 4; text: Config.theme.monoFont
                        onTextEdited: { Config.theme.monoFont = text; }
                    }
                }
                Text { text: "Mono Font"; color: Appearance.colors.textSecondary; font.family: Appearance.font.family.main }
            }
            RowLayout {
                spacing: 20
                Rectangle {
                    Layout.preferredWidth: 300
                    Layout.preferredHeight: 30
                    color: Appearance.colors.surfaceVariant
                    radius: Appearance.sizes.cornerRadius
                    StyledTextInput {
                        anchors.fill: parent; anchors.margins: 4; text: Config.theme.nerdFont
                        onTextEdited: { Config.theme.nerdFont = text; }
                    }
                }
                Text { text: "Nerd Font"; color: Appearance.colors.textSecondary; font.family: Appearance.font.family.main }
            }
            RowLayout {
                spacing: 20
                Rectangle {
                    Layout.preferredWidth: 300
                    Layout.preferredHeight: 30
                    color: Appearance.colors.surfaceVariant
                    radius: Appearance.sizes.cornerRadius
                    StyledTextInput {
                        anchors.fill: parent; anchors.margins: 4; text: Config.theme.iconFont
                        onTextEdited: { Config.theme.iconFont = text; }
                    }
                }
                Text { text: "Icon Font"; color: Appearance.colors.textSecondary; font.family: Appearance.font.family.main }
            }
            RowLayout {
                spacing: 20
                Rectangle {
                    Layout.preferredWidth: 300
                    Layout.preferredHeight: 30
                    color: Appearance.colors.surfaceVariant
                    radius: Appearance.sizes.cornerRadius
                    StyledTextInput {
                        anchors.fill: parent; anchors.margins: 4; text: Config.theme.titleFont
                        onTextEdited: { Config.theme.titleFont = text; }
                    }
                }
                Text { text: "Title Font"; color: Appearance.colors.textSecondary; font.family: Appearance.font.family.main }
            }
        }
    }
    
    ContentSection {
        title: "Background"
        icon: "image"
        space: root.gap
        
        ContentSubsection {
            title: "Wallpaper Paths"
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 30
                color: Appearance.colors.surfaceVariant
                radius: Appearance.sizes.cornerRadius
                StyledTextInput {
                    anchors.fill: parent
                    anchors.margins: 4
                    text: Config.background.wallpaperPaths[0] || ""
                    onTextEdited: {
                        var paths = Config.background.wallpaperPaths
                        if (paths.length > 0) paths[0] = text
                        else paths.push(text)
                        Config.background.wallpaperPaths = paths
                    }
                }
            }
        }
        
        ToggleButton {
            title: "Copy On Update"
            subtitle: "Copy the current wallpaper to somewhere when it updates"
            hasIcon: false
            checked: Config.background.copyAfter
            onClicked: Config.background.copyAfter = !Config.background.copyAfter
        }

        RowLayout {
            Layout.fillWidth: true

            ContentSubsection {
                title: "Copy To"
                Rectangle {
                    Layout.fillWidth: true
                    Layout.minimumWidth: 530
                    Layout.preferredHeight: 30
                    color: Appearance.colors.surfaceVariant
                    radius: Appearance.sizes.cornerRadius
                    StyledTextInput {
                        anchors.fill: parent
                        anchors.margins: 4
                        text: Config.background.copyAfterTo || ""
                        onTextEdited: {
                            Config.background.copyAfterTo = text
                        }
                    }
                }
            }

            ContentSubsection {
                title: "As"
                Rectangle {
                    Layout.preferredWidth: 200
                    Layout.preferredHeight: 30
                    color: Appearance.colors.surfaceVariant
                    radius: Appearance.sizes.cornerRadius
                    StyledTextInput {
                        anchors.fill: parent
                        anchors.margins: 4
                        text: Config.background.copyAfterAs || ""
                        onTextEdited: {
                            Config.background.copyAfterAs = text
                        }
                    }
                }
            }
        }
    }
    
    ContentSection {
        title: "Control Center"
        icon: "tune"
        space: root.gap
        
        ContentSubsection {
            title: "Position"
            ConfigSelectionArray {
                options: [
                    { displayName: "Left", value: "left" },
                    { displayName: "Right", value: "right" }
                ]
                currentValue: Config.controlCenter.position
                onSelected: (val) => Config.controlCenter.position = val
            }
        }
        
        ContentSubsection {
            title: "Width"
            Rectangle {
                Layout.preferredWidth: 100
                Layout.preferredHeight: 30
                color: Appearance.colors.surfaceVariant
                radius: Appearance.sizes.cornerRadius
                StyledTextInput {
                    anchors.fill: parent
                    anchors.margins: 4
                    text: Config.controlCenter.width.toString()
                    onTextEdited: {
                        var val = parseInt(text)
                        if (!isNaN(val)) Config.controlCenter.width = Math.max(300, Math.min(500, val))
                    }
                }
            }
        }
        
        ContentSubsection {
            ToggleButton {
                title: "Profile Picture"
                subtitle: "Shows profile picture in control center"
                hasIcon: false
                checked: Config.controlCenter.showPfp
                onClicked: Config.controlCenter.showPfp = !Config.controlCenter.showPfp
            }
        }
    }
    
    ContentSection {
        title: "Notifications"
        icon: "notifications"
        space: root.gap
        
        ContentSubsection {
            title: "Position"
            ConfigSelectionArray {
                options: [
                    { displayName: "Top Left", value: "top-left" },
                    { displayName: "Top Right", value: "top-right" },
                    { displayName: "Bottom Left", value: "bottom-left" },
                    { displayName: "Bottom Right", value: "bottom-right" },
                ]
                currentValue: Config.notifications.position
                onSelected: (val) => Config.notifications.position = val
            }
        }
        
        ContentSubsection {
            title: "Limits"
            RowLayout {
                spacing: 20
                Rectangle {
                    Layout.preferredWidth: 100
                    Layout.preferredHeight: 30
                    color: Appearance.colors.surfaceVariant
                    radius: Appearance.sizes.cornerRadius
                    StyledTextInput {
                        anchors.fill: parent; anchors.margins: 4; text: Config.notifications.maxNotifications.toString()
                        onTextEdited: { var val = parseInt(text); if(!isNaN(val)) Config.notifications.maxNotifications = Math.max(1, Math.min(10, val)); }
                    }
                }
                Text { text: "Max Count"; color: Appearance.colors.textSecondary; font.family: Appearance.font.family.main }
            }
             RowLayout {
                spacing: 20
                Rectangle {
                    Layout.preferredWidth: 100
                    Layout.preferredHeight: 30
                    color: Appearance.colors.surfaceVariant
                    radius: Appearance.sizes.cornerRadius
                    StyledTextInput {
                        anchors.fill: parent; anchors.margins: 4; text: Config.notifications.groupAt.toString()
                        onTextEdited: { var val = parseInt(text); if(!isNaN(val)) Config.notifications.groupAt = Math.max(2, Math.min(10, val)); }
                    }
                }
                Text { text: "Group At"; color: Appearance.colors.textSecondary; font.family: Appearance.font.family.main }
            }
        }
         ContentSubsection {
            title: "Timeout (ms)"
            Rectangle {
                Layout.preferredWidth: 100
                Layout.preferredHeight: 30
                color: Appearance.colors.surfaceVariant
                radius: Appearance.sizes.cornerRadius
                StyledTextInput {
                    anchors.fill: parent; anchors.margins: 4; text: Config.notifications.timeout.toString()
                    onTextEdited: { var val = parseInt(text); if(!isNaN(val)) Config.notifications.timeout = val; }
                }
            }
        }
    }
    
    ContentSection {
        title: "OSD Popup"
        icon: "visibility"
        space: root.gap
        
        ContentSubsection {
            title: "Position"
            ConfigSelectionArray {
                options: [
                    { displayName: "Top Left", value: "top-left" },
                    { displayName: "Top Center", value: "top-center" },
                    { displayName: "Top Right", value: "top-right" },
                    { displayName: "Bottom Left", value: "bottom-left" },
                    { displayName: "Bottom Center", value: "bottom-center" },
                    { displayName: "Bottom Right", value: "bottom-right" },
                ]
                currentValue: Config.osd.position
                onSelected: (val) => Config.osd.position = val
            }
        }
         ContentSubsection {
            title: "Timeout (ms)"
            Rectangle {
                Layout.preferredWidth: 100
                Layout.preferredHeight: 30
                color: Appearance.colors.surfaceVariant
                radius: Appearance.sizes.cornerRadius
                StyledTextInput {
                    anchors.fill: parent; anchors.margins: 4; text: Config.osd.timeout.toString()
                    onTextEdited: { var val = parseInt(text); if(!isNaN(val)) Config.osd.timeout = val; }
                }
            }
        }
    }
}

