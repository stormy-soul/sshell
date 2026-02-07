import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Qt5Compat.GraphicalEffects
import "../../components/settings"
import "../../components/common"
import "../../services"
import "../"

ContentPage {
    id: root
    property int gap: 15

    ContentSection {
        title: "Wallpaper"
        icon: "image"
        
        ContentSubsection {
            RowLayout {
                Layout.fillWidth: true
                Rectangle {
                    Layout.preferredWidth: 320
                    Layout.preferredHeight: 180
                    color: Appearance.colors.surfaceVariant
                    radius: Appearance.sizes.cornerRadius

                    MaterialIcon {
                        icon: "imagesearch_roller"
                        color: Appearance.colors.textSecondary
                        width: 80
                        height: 80
                        anchors.centerIn: parent
                        visible: wallpaperThumb.status !== Image.Ready
                    }
                    
                    Image {
                        id: wallpaperThumb
                        anchors.fill: parent
                        source: WallpaperService.currentWallpaper && WallpaperService.currentWallpaper !== "" ? "file://" + WallpaperService.currentWallpaper : ""
                        fillMode: Image.PreserveAspectCrop
                        asynchronous: true
                        sourceSize.width: 320
                        sourceSize.height: 180
                        
                        layer.enabled: true
                        layer.effect: OpacityMask {
                            maskSource: Rectangle {
                                width: wallpaperThumb.width
                                height: wallpaperThumb.height
                                radius: Appearance.sizes.cornerRadius
                            }
                        }
                    }
                }   
                
                ColumnLayout {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Rectangle {
                        Layout.preferredWidth: 120
                        Layout.preferredHeight: 88
                        color: Appearance.colors.surfaceVariant
                        radius: Appearance.sizes.cornerRadius
                        
                        MaterialIcon {
                            icon: "hide_image"
                            color: Appearance.colors.textSecondary
                            width: 40
                            height: 40
                            anchors.centerIn: parent
                        }
                    }
                    Rectangle {
                        Layout.preferredWidth: 120
                        Layout.preferredHeight: 88
                        color: Appearance.colors.surfaceVariant
                        radius: Appearance.sizes.cornerRadius
                        
                        MaterialIcon {
                            icon: "shuffle"
                            color: Appearance.colors.textSecondary
                            width: 40
                            height: 40
                            anchors.centerIn: parent
                        }
                    }
                }
            }
        }
    }

    ContentSection {
        title: "Theme"
        icon: "palette"
        space: root.gap
        
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
            RowLayout {
                Layout.fillWidth: true
                ToggleButton {
                    title: "Colorize Terminal"
                    subtitle: "Use generated colors in the terminal"
                    hasIcon: false
                    checked: Config.theme.colorizeTerminal
                    onClicked: Config.theme.colorizeTerminal = !Config.theme.colorizeTerminal
                }
            }
            RowLayout {
                Layout.fillWidth: true
                ToggleButton {
                    title: "Dark Mode"
                    subtitle: "Toggle dark mode"
                    hasIcon: false
                    checked: Config.theme.darkmode
                    onClicked: Config.theme.darkmode = !Config.theme.darkmode
                }
            }
        }

        ContentSubsection {
            title: "Bar Style"
            ConfigSelectionArray {
                options: [
                    { displayName: "Floating", value: "floating" },
                    { displayName: "Modules", value: "modules" },
                    { displayName: "Islands", value: "islands" },
                    { displayName: "Full", value: "full" }
                ]
                currentValue: Config.bar.style
                onSelected: (val) => Config.bar.style = val
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
                        anchors.fill: parent; anchors.margins: 4; text: Config.theme.titleFont
                        onTextEdited: { Config.theme.titleFont = text; }
                    }
                }
                Text { text: "Title Font"; color: Appearance.colors.textSecondary; font.family: Appearance.font.family.main }
            }
        }
    }    

    ContentSection {
        title: "Workspaces"
        icon: "workspaces"
        space: root.gap

        ContentSubsection {
            title: "Style"
            ConfigSelectionArray {
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


}