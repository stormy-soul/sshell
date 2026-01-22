import QtQuick

import "../../services"
import "../../theme"

Rectangle {
    id: controlCenter
    color: Theme.background
    radius: Theme.cornerRadius
    border.color: Theme.border
    border.width: 1

    Column {
        anchors.fill: parent
        anchors.margins: Theme.paddingLarge
        spacing: Theme.paddingLarge

        // Header
        Row {
            width: parent.width
            spacing: Theme.padding

            Text {
                text: "Control Center"
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSizeMassive
                font.weight: Font.Bold
                color: Theme.text
                verticalAlignment: Text.AlignVCenter
            }

            Item {
                width: parent.width - 200
            }

            Rectangle {
                width: 32
                height: 32
                radius: Theme.cornerRadiusSmall
                color: closeMouseArea.containsMouse ? Theme.surface : "transparent"

                Text {
                    anchors.centerIn: parent
                    text: "󰅖"
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSize
                    color: Theme.text
                }

                MouseArea {
                    id: closeMouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: controlCenterWindow.visible = false
                }
            }
        }

        // Quick Settings Cards
        Column {
            width: parent.width
            spacing: Theme.padding

            // Volume Card
            Rectangle {
                width: parent.width
                height: 80
                radius: Theme.cornerRadiusSmall
                color: Theme.surface

                Column {
                    anchors.fill: parent
                    anchors.margins: Theme.padding
                    spacing: Theme.paddingSmall

                    Row {
                        width: parent.width

                        Text {
                            text: "󰕾 Volume"
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontSize
                            color: Theme.text
                        }

                        Item {
                            width: parent.width - 150
                        }

                        Text {
                            text: "50%"
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontSizeSmall
                            color: Theme.textSecondary
                        }
                    }

                    Rectangle {
                        width: parent.width
                        height: 4
                        radius: 2
                        color: Theme.surfaceVariant

                        Rectangle {
                            width: parent.width * 0.5
                            height: parent.height
                            radius: parent.radius
                            color: Theme.accent
                        }
                    }
                }
            }

            // Network Card
            Rectangle {
                width: parent.width
                height: 60
                radius: Theme.cornerRadiusSmall
                color: Theme.surface

                Row {
                    anchors.fill: parent
                    anchors.margins: Theme.padding
                    spacing: Theme.padding

                    Text {
                        text: "󰖩"
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSizeLarge
                        color: Theme.accent
                        verticalAlignment: Text.AlignVCenter
                    }

                    Column {
                        spacing: 2

                        Text {
                            text: "WiFi"
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontSize
                            color: Theme.text
                        }

                        Text {
                            text: "Connected"
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontSizeSmall
                            color: Theme.textSecondary
                        }
                    }
                }
            }

            // Bluetooth Card
            Rectangle {
                width: parent.width
                height: 60
                radius: Theme.cornerRadiusSmall
                color: Theme.surface

                Row {
                    anchors.fill: parent
                    anchors.margins: Theme.padding
                    spacing: Theme.padding

                    Text {
                        text: "󰂯"
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSizeLarge
                        color: Theme.textSecondary
                        verticalAlignment: Text.AlignVCenter
                    }

                    Column {
                        spacing: 2

                        Text {
                            text: "Bluetooth"
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontSize
                            color: Theme.text
                        }

                        Text {
                            text: "Off"
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontSizeSmall
                            color: Theme.textSecondary
                        }
                    }
                }
            }
        }
    }
}