import QtQuick
import Quickshell
import "../../settings"
import "../../services"

PanelWindow {
    id: popupsWindow
    
    implicitWidth: Appearance.sizes.notificationWidth
    implicitHeight: Quickshell.screens[0].height
    screen: Quickshell.screens[0]
    color: "transparent"

    exclusionMode: ExclusionMode.Ignore
    property string position: Config.notifications.position || "top-right"

    anchors {
        top: position.startsWith("top")
        bottom: position.startsWith("bottom")
        left: position.endsWith("left")
        right: position.endsWith("right")
    }

    margins {
        top: Appearance.sizes.paddingLarge
        bottom: Appearance.sizes.paddingLarge
        left: Appearance.sizes.paddingLarge
        right: Appearance.sizes.paddingLarge
    }

    mask: Region {
        item: notificationColumn
    }

    Column {
        id: notificationColumn
        spacing: Appearance.sizes.padding
        width: parent.width

        Repeater {
            model: NotificationService.notifications.slice(0, Config.notifications.maxNotifications || 5)

            Rectangle {
                required property var modelData

                width: Appearance.sizes.notificationWidth
                height: Appearance.sizes.notificationHeight
                radius: Appearance.sizes.cornerRadius
                color: Appearance.colors.background
                border.color: Appearance.colors.border
                border.width: 1

                opacity: 0
                y: -20

                Component.onCompleted: {
                    opacity = 1
                    y = 0
                }

                Behavior on opacity {
                    NumberAnimation { duration: Appearance.animation.duration }
                }

                Behavior on y {
                    NumberAnimation { duration: Appearance.animation.duration }
                }

                Row {
                    anchors.fill: parent
                    anchors.margins: Appearance.sizes.padding
                    spacing: Appearance.sizes.padding

                    Column {
                        width: parent.width - 40
                        spacing: Appearance.sizes.paddingSmall

                        Text {
                            width: parent.width
                            text: parent.parent.parent.modelData.title
                            font.family: Appearance.font.family.main
                            font.pixelSize: Appearance.font.pixelSize.normal
                            font.weight: Font.DemiBold
                            color: Appearance.colors.text
                            elide: Text.ElideRight
                        }

                        Text {
                            width: parent.width
                            text: parent.parent.parent.modelData.body
                            font.family: Appearance.font.family.main
                            font.pixelSize: Appearance.font.pixelSize.small
                            color: Appearance.colors.textSecondary
                            wrapMode: Text.WordWrap
                            maximumLineCount: 2
                            elide: Text.ElideRight
                        }
                    }

                    Rectangle {
                        width: 24
                        height: 24
                        radius: Appearance.sizes.cornerRadiusSmall
                        color: closeArea.containsMouse ? Appearance.colors.surface : "transparent"

                        Text {
                            anchors.centerIn: parent
                            text: "󰅖"
                            font.family: Appearance.font.family.nerd
                            font.pixelSize: Appearance.font.pixelSize.small
                            color: Appearance.colors.text
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