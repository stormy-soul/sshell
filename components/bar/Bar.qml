import QtQuick
import "../../settings"
import "../../services"

Rectangle {
    id: bar
    color: Appearance.colors.background
    radius: Appearance.sizes.cornerRadiusLarge
    opacity: 1
    border.width: 1
    border.color: Qt.rgba(Appearance.colors.border.r, Appearance.colors.border.g, Appearance.colors.border.b, 0.1)

    anchors.fill: parent

    Row {
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        anchors.leftMargin: Appearance.sizes.padding * 2
        spacing: Appearance.sizes.padding

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
        spacing: Appearance.sizes.padding

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
        anchors.rightMargin: Appearance.sizes.padding * 2
        spacing: Appearance.sizes.padding

        Loader {
            anchors.verticalCenter: parent.verticalCenter
            source: "modules/TrayToggle.qml"
            active: {
                for (var i = 0; i < Config.bar.right.length; i++) {
                     if (Config.bar.right[i].module === "Tray" && Config.bar.right[i].enabled) return true;
                }
                return false;
            }
        }

        Repeater {
            model: Config.bar.right
            Loader {
                anchors.verticalCenter: parent.verticalCenter
                source: "modules/" + modelData.module + ".qml"
                active: modelData.enabled && modelData.module !== "TrayToggle" // hide duplicate if exists
            }
        }
    }
}