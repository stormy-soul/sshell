import QtQuick
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects
import Quickshell
import Quickshell.Wayland
import "../../settings"
import "../../services"
import "../../components"

PanelWindow {
    id: popupsWindow
    
    implicitWidth: Appearance.sizes.notificationWidth
    implicitHeight: Quickshell.screens[0].height
    screen: Quickshell.screens[0]
    color: "transparent"

    WlrLayershell.namespace: "sshell:notifications"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

    exclusionMode: ExclusionMode.Ignore
    property string position: Config.notifications.position || "top-right"

    anchors {
        top: position.startsWith("top")
        bottom: position.startsWith("bottom")
        left: position.endsWith("left")
        right: position.endsWith("right")
    }

    margins {
        top: Appearance.sizes.paddingLarge + (Config.bar.position === "top" ? Appearance.sizes.barHeight + Appearance.sizes.barMargin : 0)
        bottom: Appearance.sizes.paddingLarge + (Config.bar.position === "bottom" ? Appearance.sizes.barHeight + Appearance.sizes.barMargin : 0)
        left: Appearance.sizes.paddingLarge
        right: Appearance.sizes.paddingLarge
    }

    mask: Region {
        item: ShellState.masterVisible ? notificationColumn : null
    } 
    Column {
        id: notificationColumn
        opacity: ShellState.masterVisible ? 1 : 0
        spacing: Appearance.sizes.padding
        width: parent.width

        Repeater {
            model: NotificationService.notifications.filter(n => n.shownInPopup).slice(0, Config.notifications.maxNotifications || 5)

            Rectangle {
                required property var modelData

                width: Appearance.sizes.notificationWidth || 350
                height: content.height + (Appearance.sizes.paddingLarge * 2)
                radius: Appearance.sizes.cornerRadiusLarge
                color: Appearance.colors.overlayBackground
                border.color: Qt.rgba(Appearance.colors.border.r, Appearance.colors.border.g, Appearance.colors.border.b, 0.2)
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

                
                MouseArea {
                    id: hoverArea
                    anchors.fill: parent
                    hoverEnabled: true
                    propagateComposedEvents: true
                    
                    onEntered: NotificationService.pauseTimer(modelData.id)
                    onExited: NotificationService.resumeTimer(modelData.id)
                    
                    onPressed: mouse.accepted = false
                }

                RowLayout {
                    id: content
                    width: parent.width
                    anchors {
                        top: parent.top
                        left: parent.left
                        right: parent.right
                        margins: Appearance.sizes.paddingLarge
                    }
                    spacing: 12

                    Item {
                        Layout.preferredWidth: 40
                        Layout.preferredHeight: 40
                        Layout.alignment: Qt.AlignTop
                        
                        MaterialIcon {
                            anchors.centerIn: parent
                            visible: !imageIcon.visible
                            icon: imageIcon.visible ? "notifications" : (modelData.image || "notifications") 
                            width: 32
                            height: 32
                            color: Appearance.colors.accent
                        }

                        Image {
                            id: imageIcon
                            anchors.fill: parent
                            visible: modelData.image && (modelData.image.startsWith("/") || modelData.image.startsWith("image://"))
                            source: visible ? (modelData.image.startsWith("/") ? "file://" + modelData.image : modelData.image) : ""
                            fillMode: Image.PreserveAspectCrop
                            layer.enabled: true
                            layer.effect: OpacityMask {
                                maskSource: Rectangle {
                                    width: imageIcon.width
                                    height: imageIcon.height
                                    radius: Appearance.sizes.cornerRadiusSmall
                                    visible: false
                                }
                            }
                        }
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 4

                        RowLayout {
                            Layout.fillWidth: true
                            Text {
                                Layout.fillWidth: true
                                text: modelData.title
                                font.family: Appearance.font.family.main
                                font.pixelSize: Appearance.font.pixelSize.normal
                                font.weight: Font.DemiBold
                                color: Appearance.colors.text
                                elide: Text.ElideRight
                            }
                            
                            Rectangle {
                                Layout.preferredWidth: 20
                                Layout.preferredHeight: 20
                                radius: 10
                                color: closeArea.containsMouse ? Appearance.colors.surface : "transparent"
                                
                                MaterialIcon {
                                    anchors.centerIn: parent
                                    icon: "close"
                                    width: 12
                                    height: 12
                                    color: Appearance.colors.textSecondary
                                }

                                MouseArea {
                                    id: closeArea
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    onClicked: NotificationService.expire(modelData.id)
                                }
                            }
                        }

                        Text {
                            Layout.fillWidth: true
                            text: modelData.body
                            font.family: Appearance.font.family.main
                            font.pixelSize: Appearance.font.pixelSize.small
                            color: Appearance.colors.textSecondary
                            wrapMode: Text.WordWrap
                            maximumLineCount: 3
                            elide: Text.ElideRight
                        }
                    }
                }
            }
        }
    }

}