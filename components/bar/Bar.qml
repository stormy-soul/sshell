import QtQuick
import "../../settings"
import "../../services"

Rectangle {
    id: bar

    readonly property string barStyle: Config.bar.style || "floating"
    readonly property bool isFloating: barStyle === "floating"
    readonly property bool isFull: barStyle === "full"
    readonly property bool isModules: barStyle === "modules"
    readonly property bool isIslands: barStyle === "islands"

    color: (isFloating || isFull) ? Appearance.colors.background : "transparent"
    radius: isFull ? 0 : (isFloating ? Appearance.sizes.cornerRadiusLarge : 0)
    opacity: 1
    border.width: (isFloating) ? 1 : 0
    border.color: Qt.rgba(Appearance.colors.border.r, Appearance.colors.border.g, Appearance.colors.border.b, 0.1)

    anchors.fill: parent

    Rectangle {
        id: leftIsland
        visible: isIslands && leftRow.children.length > 0
        color: Appearance.colors.background
        radius: Appearance.sizes.cornerRadiusLarge
        border.width: 1
        border.color: Qt.rgba(Appearance.colors.border.r, Appearance.colors.border.g, Appearance.colors.border.b, 0.1)

        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        anchors.leftMargin: Appearance.sizes.padding

        width: leftRow.width + Appearance.sizes.padding * 2
        height: parent.height
    }

    Row {
        id: leftRow
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        anchors.leftMargin: isIslands ? Appearance.sizes.padding * 2 : Appearance.sizes.padding * 2
        spacing: isModules ? Appearance.sizes.paddingLarge * 2 : Appearance.sizes.padding

        Repeater {
            model: Config.bar.left
            Loader {
                anchors.verticalCenter: parent.verticalCenter
                source: "modules/" + modelData.module + ".qml"
                active: modelData.enabled

                Rectangle {
                    z: -1
                    visible: isModules && parent.item
                    anchors.centerIn: parent
                    width: parent.width + Appearance.sizes.padding * 2
                    height: Config.bar.height
                    color: Appearance.colors.background
                    radius: Appearance.sizes.cornerRadiusLarge
                    border.width: 1
                    border.color: Qt.rgba(Appearance.colors.border.r, Appearance.colors.border.g, Appearance.colors.border.b, 0.1)
                }
            }
        }
    }

    Rectangle {
        id: centerIsland
        visible: isIslands && centerRow.children.length > 0
        color: Appearance.colors.background
        radius: Appearance.sizes.cornerRadiusLarge
        border.width: 1
        border.color: Qt.rgba(Appearance.colors.border.r, Appearance.colors.border.g, Appearance.colors.border.b, 0.1)

        anchors.centerIn: parent

        width: centerRow.width + Appearance.sizes.padding * 2
        height: parent.height
    }

    Row {
        id: centerRow
        anchors.centerIn: parent
        spacing: isModules ? Appearance.sizes.paddingLarge * 2 : Appearance.sizes.padding

        Repeater {
            model: Config.bar.center
            Loader {
                anchors.verticalCenter: parent.verticalCenter
                source: "modules/" + modelData.module + ".qml"
                active: modelData.enabled

                Rectangle {
                    z: -1
                    visible: isModules && parent.item
                    anchors.centerIn: parent
                    width: parent.width + Appearance.sizes.padding * 2
                    height: Config.bar.height
                    color: Appearance.colors.background
                    radius: Appearance.sizes.cornerRadiusLarge
                    border.width: 1
                    border.color: Qt.rgba(Appearance.colors.border.r, Appearance.colors.border.g, Appearance.colors.border.b, 0.1)
                }
            }
        }
    }

    Rectangle {
        id: rightIsland
        visible: isIslands && rightRow.children.length > 0
        color: Appearance.colors.background
        radius: Appearance.sizes.cornerRadiusLarge
        border.width: 1
        border.color: Qt.rgba(Appearance.colors.border.r, Appearance.colors.border.g, Appearance.colors.border.b, 0.1)

        anchors.verticalCenter: parent.verticalCenter
        anchors.right: parent.right
        anchors.rightMargin: Appearance.sizes.padding

        width: rightRow.width + Appearance.sizes.padding * 2
        height: parent.height
    }

    Row {
        id: rightRow
        anchors.verticalCenter: parent.verticalCenter
        anchors.right: parent.right
        anchors.rightMargin: isIslands ? Appearance.sizes.padding * 2 : Appearance.sizes.padding * 2
        spacing: isModules ? Appearance.sizes.paddingLarge * 2 : Appearance.sizes.padding

        Loader {
            anchors.verticalCenter: parent.verticalCenter
            source: "modules/TrayToggle.qml"
            active: {
                for (var i = 0; i < Config.bar.right.length; i++) {
                     if (Config.bar.right[i].module === "Tray" && Config.bar.right[i].enabled) return true;
                }
                return false;
            }

            Rectangle {
                z: -1
                visible: isModules && parent.item
                anchors.centerIn: parent
                width: parent.width + Appearance.sizes.padding * 2
                height: Config.bar.height
                color: Appearance.colors.background
                radius: Appearance.sizes.cornerRadiusLarge
                border.width: 1
                border.color: Qt.rgba(Appearance.colors.border.r, Appearance.colors.border.g, Appearance.colors.border.b, 0.1)
            }
        }

        Repeater {
            model: Config.bar.right
            Loader {
                anchors.verticalCenter: parent.verticalCenter
                source: "modules/" + modelData.module + ".qml"
                active: modelData.enabled && modelData.module !== "TrayToggle" // hide duplicate if exists

                Rectangle {
                    z: -1
                    visible: isModules && parent.item
                    anchors.centerIn: parent
                    width: parent.width + Appearance.sizes.padding * 2
                    height: Config.bar.height
                    color: Appearance.colors.background
                    radius: Appearance.sizes.cornerRadiusLarge
                    border.width: 1
                    border.color: Qt.rgba(Appearance.colors.border.r, Appearance.colors.border.g, Appearance.colors.border.b, 0.1)
                }
            }
        }
    }
}