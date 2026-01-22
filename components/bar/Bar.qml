import QtQuick
import Quickshell

import "../../services"
import "../../theme"

Rectangle {
    id: bar
    color: Theme.background
    radius: Theme.cornerRadius

    Rectangle {
        anchors.fill: parent
        border.color: Theme.border
        border.width: 1
        radius: parent.radius
        opacity: 0.3
    }

    Row {
        id: leftModules
        anchors {
            left: parent.left
            leftMargin: Theme.padding
            verticalCenter: parent.verticalCenter
        }
        spacing: Theme.gap

        Repeater {
            model: Config.options.bar.left

            Loader {
                required property var modelData
                active: modelData.enabled
                source: modelData.enabled ? Qt.resolvedUrl(`modules/${modelData.module}.qml`) : ""

                onStatusChanged: {
                    if (status === Loader.Error) {
                        console.warn(`Failed to load module: ${modelData.module}`)
                    }
                }
            }
        }
    }

    Row {
        id: centerModules
        anchors.centerIn: parent
        spacing: Theme.gap

        Repeater {
            model: Config.options.bar.center

            Loader {
                required property var modelData
                active: modelData.enabled
                source: modelData.enabled ? Qt.resolvedUrl(`modules/${modelData.module}.qml`) : ""
            }
        }
    }

    Row {
        id: rightModules
        anchors {
            right: parent.right
            rightMargin: Theme.padding
            verticalCenter: parent.verticalCenter
        }
        spacing: Theme.gap

        Repeater {
            model: Config.options.bar.right

            Loader {
                required property var modelData
                active: modelData.enabled
                source: modelData.enabled ? Qt.resolvedUrl(`modules/${modelData.module}.qml`) : ""
            }
        }
    }
}