import QtQuick
import Quickshell.Io

import "../../services"
import "../../theme"

Rectangle {
    id: launcher
    color: Theme.background
    radius: Theme.cornerRadius
    border.color: Theme.border
    border.width: 1

    signal launchApp

    Column {
        anchors.fill: parent
        anchors.margins: Theme.paddingLarge
        spacing: Theme.paddingLarge

        // Search bar
        Rectangle {
            width: parent.width
            height: 48
            radius: Theme.cornerRadiusSmall
            color: Theme.surface
            border.color: searchInput.activeFocus ? Theme.accent : Theme.border
            border.width: 2

            Row {
                anchors.fill: parent
                anchors.margins: Theme.padding
                spacing: Theme.padding

                Text {
                    text: "󰍉"
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSizeLarge
                    color: Theme.textSecondary
                    verticalAlignment: Text.AlignVCenter
                }

                TextInput {
                    id: searchInput
                    width: parent.width - 40
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSize
                    color: Theme.text
                    verticalAlignment: TextInput.AlignVCenter
                    selectByMouse: true

                    Text {
                        visible: parent.text.length === 0
                        text: "Search applications..."
                        font: parent.font
                        color: Theme.textSecondary
                        verticalAlignment: Text.AlignVCenter
                    }

                    Keys.onEscapePressed: launcherWindow.visible = false
                }
            }
        }

        // App list
        GridView {
            width: parent.width
            height: parent.height - 80
            cellWidth: width / 4
            cellHeight: 100
            clip: true

            model: ListModel {
                ListElement {
                    name: "LibreWolf"
                    icon: "librewolf"
                    exec: "librewolf"
                }
                ListElement {
                    name: "Terminal"
                    icon: "terminal"
                    exec: "kitty"
                }
                ListElement {
                    name: "Files"
                    icon: "folder"
                    exec: "thunar"
                }
                ListElement {
                    name: "Settings"
                    icon: "settings"
                    exec: "xfce4-settings"
                }
            }

            delegate: Rectangle {
                required property string name
                required property string exec
                
                width: GridView.view.cellWidth - Theme.padding
                height: GridView.view.cellHeight - Theme.padding
                radius: Theme.cornerRadiusSmall
                color: appMouseArea.containsMouse ? Theme.surface : "transparent"

                Column {
                    anchors.centerIn: parent
                    spacing: Theme.paddingSmall

                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: "󰀻"
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSizeMassive
                        color: Theme.accent
                    }

                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: parent.parent.name
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSizeSmall
                        color: Theme.text
                    }
                }

                MouseArea {
                    id: appMouseArea
                    anchors.fill: parent
                    hoverEnabled: true

                    onClicked: {
                        var proc = Qt.createQmlObject(
                            'import Quickshell.Io; Process { command: ["' + exec + '"]; running: true }',
                            launcher,
                            "dynamicProcess"
                        )
                        launcher.launchApp()
                    }
                }
            }
        }
    }
}