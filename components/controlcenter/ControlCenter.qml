import QtQuick
import "../../settings"
import "../../services"

Rectangle {
    id: controlCenter
    color: Appearance.colors.background
    radius: Appearance.sizes.cornerRadius
    border.color: Appearance.colors.border
    border.width: 1

    Column {
        anchors.fill: parent
        anchors.margins: Appearance.sizes.paddingLarge
        spacing: Appearance.sizes.paddingLarge

        Row {
            width: parent.width
            spacing: Appearance.sizes.padding

            Text {
                text: "Control Center"
                font.family: Appearance.font.family.main
                font.pixelSize: Appearance.font.pixelSize.massive
                font.weight: Font.Bold
                color: Appearance.colors.text
                verticalAlignment: Text.AlignVCenter
            }

            Item { width: parent.width - 200 }

            Rectangle {
                width: 32
                height: 32
                radius: Appearance.sizes.cornerRadiusSmall
                color: closeMouseArea.containsMouse ? Appearance.colors.surface : "transparent"

                Text {
                    anchors.centerIn: parent
                    text: "󰅖"
                    font.family: Appearance.font.family.nerd
                    font.pixelSize: Appearance.font.pixelSize.normal
                    color: Appearance.colors.text
                }

                MouseArea {
                    id: closeMouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: controlCenterWindow.visible = false
                }
            }
        }

        Column {
            width: parent.width
            spacing: Appearance.sizes.padding

            Rectangle {
                width: parent.width
                height: 80
                radius: Appearance.sizes.cornerRadiusSmall
                color: Appearance.colors.surface

                Column {
                    anchors.fill: parent
                    anchors.margins: Appearance.sizes.padding
                    spacing: Appearance.sizes.paddingSmall

                    Row {
                        width: parent.width

                        Text {
                            text: "󰕾 Volume"
                            font.family: Appearance.font.family.nerd
                            font.pixelSize: Appearance.font.pixelSize.normal
                            color: Appearance.colors.text
                        }

                        Item { width: parent.width - 150 }

                        Text {
                            text: "50%"
                            font.family: Appearance.font.family.main
                            font.pixelSize: Appearance.font.pixelSize.small
                            color: Appearance.colors.textSecondary
                        }
                    }

                    Rectangle {
                        width: parent.width
                        height: 4
                        radius: 2
                        color: Appearance.colors.surfaceVariant

                        Rectangle {
                            width: parent.width * 0.5
                            height: parent.height
                            radius: parent.radius
                            color: Appearance.colors.accent
                        }
                    }
                }
            }

            Rectangle {
                width: parent.width
                height: 60
                radius: Appearance.sizes.cornerRadiusSmall
                color: Appearance.colors.surface

                Row {
                    anchors.fill: parent
                    anchors.margins: Appearance.sizes.padding
                    spacing: Appearance.sizes.padding

                    Text {
                        text: "󰖩"
                        font.family: Appearance.font.family.nerd
                        font.pixelSize: Appearance.font.pixelSize.large
                        color: Appearance.colors.accent
                        verticalAlignment: Text.AlignVCenter
                    }

                    Column {
                        spacing: 2

                        Text {
                            text: "WiFi"
                            font.family: Appearance.font.family.main
                            font.pixelSize: Appearance.font.pixelSize.normal
                            color: Appearance.colors.text
                        }

                        Text {
                            text: "Connected"
                            font.family: Appearance.font.family.main
                            font.pixelSize: Appearance.font.pixelSize.small
                            color: Appearance.colors.textSecondary
                        }
                    }
                }
            }

            Rectangle {
                width: parent.width
                height: 60
                radius: Appearance.sizes.cornerRadiusSmall
                color: Appearance.colors.surface

                Row {
                    anchors.fill: parent
                    anchors.margins: Appearance.sizes.padding
                    spacing: Appearance.sizes.padding

                    Text {
                        text: "󰂯"
                        font.family: Appearance.font.family.nerd
                        font.pixelSize: Appearance.font.pixelSize.large
                        color: Appearance.colors.textSecondary
                        verticalAlignment: Text.AlignVCenter
                    }

                    Column {
                        spacing: 2

                        Text {
                            text: "Bluetooth"
                            font.family: Appearance.font.family.main
                            font.pixelSize: Appearance.font.pixelSize.normal
                            color: Appearance.colors.text
                        }

                        Text {
                            text: "Off"
                            font.family: Appearance.font.family.main
                            font.pixelSize: Appearance.font.pixelSize.small
                            color: Appearance.colors.textSecondary
                        }
                    }
                }
            }
        }
    }
}