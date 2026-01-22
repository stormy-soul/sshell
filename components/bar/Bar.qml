import QtQuick
import "../../theme"
import "../../services"

Rectangle {
    id: bar
    color: Theme.background
    radius: Theme.cornerRadius
    opacity: 0.9

    anchors.fill: parent

    Row {
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        anchors.leftMargin: Config.bar.padding
        spacing: Config.bar.padding

        Repeater {
            model: Config.bar.left
            Loader {
                anchors.verticalCenter: parent.verticalCenter
                source: "modules/" + modelData.module + ".qml"
                active: modelData.enabled
            }
        }
    }

    Row {
        anchors.centerIn: parent
        spacing: Config.bar.padding

        Repeater {
            model: Config.bar.center
            Loader {
                anchors.verticalCenter: parent.verticalCenter
                source: "modules/" + modelData.module + ".qml"
                active: modelData.enabled
            }
        }
    }

    Row {
        anchors.verticalCenter: parent.verticalCenter
        anchors.right: parent.right
        anchors.rightMargin: Config.bar.padding
        spacing: Config.bar.padding

        Repeater {
            model: Config.bar.right
            Loader {
                anchors.verticalCenter: parent.verticalCenter
                source: "modules/" + modelData.module + ".qml"
                active: modelData.enabled
            }
        }
    }
}