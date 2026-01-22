import QtQuick
import Quickshell

FloatingWindow {
    id: popupsWindow
    
    width: 350
    height: Quickshell.screens[0].height
    screen: Quickshell.screens[0]
    color: "transparent"

    property string position: Config.notifications.position || "top-right"

    anchor {
        top: position.startsWith("top")
        bottom: position.startsWith("bottom")
        left: position.endsWith("left")
        right: position.endsWith("right")
    }

    margins {
        top: Theme.paddingLarge
        bottom: Theme.paddingLarge
        left: Theme.paddingLarge
        right: Theme.paddingLarge
    }

    Column {
        id: notificationColumn
        spacing: Theme.padding
        
        width: parent.width

        Repeater {
            model: NotificationService.notifications.slice(0, Config.notifications.maxNotifications || 5)

            Rectangle {
                required property var modelData

                width: 350
                height: 80
                radius: Theme.cornerRadius
                color: Theme.background
                border.color: Theme.border
                border.width: 1

                opacity: 0
                y: -20

                Component.onCompleted: {
                    opacity = 1
                    y = 0
                }

                Behavior on opacity {
                    NumberAnimation { duration: Theme.animationDuration }
                }

                Behavior on y {
                    NumberAnimation { duration: Theme.animationDuration }
                }

                Row {
                    anchors.fill: parent
                    anchors.margins: Theme.padding
                    spacing: Theme.padding

                    Column {
                        width: parent.width - 40
                        spacing: Theme.paddingSmall

                        Text {
                            width: parent.width
                            text: parent.parent.parent.modelData.title
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontSize
                            font.weight: Font.DemiBold
                            color: Theme.text
                            elide: Text.ElideRight
                        }

                        Text {
                            width: parent.width
                            text: parent.parent.parent.modelData.body
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontSizeSmall
                            color: Theme.textSecondary
                            wrapMode: Text.WordWrap
                            maximumLineCount: 2
                            elide: Text.ElideRight
                        }
                    }

                    Rectangle {
                        width: 24
                        height: 24
                        radius: Theme.cornerRadiusSmall
                        color: closeArea.containsMouse ? Theme.surface : "transparent"

                        Text {
                            anchors.centerIn: parent
                            text: "󰅖"
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontSizeSmall
                            color: Theme.text
                        }

                        MouseArea {
                            id: closeArea
                            anchors.fill: parent
                            hoverEnabled: true
                            onClicked: NotificationService.closeNotification(modelData.id)
                        }
                    }
                }
            }
        }
    }
}