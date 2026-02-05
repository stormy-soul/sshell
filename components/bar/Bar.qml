import QtQuick
import "../../settings"
import "../../services"

Rectangle {
    id: bar
    
    property string style: Config.barProxy.style
    readonly property bool isFloating: style === "floating"
    readonly property bool isFull: style === "full"
    readonly property bool isIslands: style === "islands"
    readonly property bool isPills: style === "pills"
    
    color: (isFloating || isFull) ? Appearance.colors.background : "transparent"
    radius: (isFull) ? 0 : Appearance.sizes.cornerRadiusLarge
    opacity: 1
    border.width: (isFloating || isFull) ? 1 : 0
    border.color: Qt.rgba(Appearance.colors.border.r, Appearance.colors.border.g, Appearance.colors.border.b, 0.1)

    anchors.fill: parent
    
    component BarSection: Rectangle {
        property alias content: container.children
        
        color: (bar.isIslands) ? Appearance.colors.background : "transparent"
        radius: Appearance.sizes.cornerRadiusLarge
        border.width: (bar.isIslands) ? 1 : 0
        border.color: Qt.rgba(Appearance.colors.border.r, Appearance.colors.border.g, Appearance.colors.border.b, 0.1)
        
        width: container.implicitWidth + (bar.isIslands ? Appearance.sizes.padding * 2 : 0)
        height: bar.height
        
        Row {
            id: container
            anchors.centerIn: parent
            spacing: Appearance.sizes.padding
        }
    }
    
    component ModuleWrapper: Rectangle {
        id: wrapper
        property alias source: loader.source
        property alias active: loader.active
        
        visible: loader.active
        
        width: loader.implicitWidth + (bar.isPills  ? Appearance.sizes.padding * 2 : 0)
        height: bar.height
        
        color: (bar.isPills) ? Appearance.colors.background : "transparent"
        radius: Appearance.sizes.cornerRadiusLarge
        border.width: (bar.isPills) ? 1 : 0
        border.color: Qt.rgba(Appearance.colors.border.r, Appearance.colors.border.g, Appearance.colors.border.b, 0.1)
        
        Loader {
            id: loader
            anchors.centerIn: parent
        }
    }

    BarSection {
        id: leftSection
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        anchors.leftMargin: (bar.isFloating || bar.isFull) ? Appearance.sizes.padding * 2 : 0
        
        content: Repeater {
            model: Config.bar.left
            ModuleWrapper {
                source: "modules/" + modelData.module + ".qml"
                active: modelData.enabled
            }
        }
    }

    BarSection {
        id: centerSection
        anchors.centerIn: parent
        
        content: Repeater {
            model: Config.bar.center
            ModuleWrapper {
                source: "modules/" + modelData.module + ".qml"
                active: modelData.enabled
            }
        }
    }

    BarSection {
        id: rightSection
        anchors.verticalCenter: parent.verticalCenter
        anchors.right: parent.right
        anchors.rightMargin: (bar.isFloating || bar.isFull) ? Appearance.sizes.padding * 2 : 0
        
        content: [
            ModuleWrapper {
                source: "modules/TrayToggle.qml"
                active: {
                    for (var i = 0; i < Config.bar.right.length; i++) {
                         if (Config.bar.right[i].module === "Tray" && Config.bar.right[i].enabled) return true;
                    }
                    return false;
                }
            },
            Repeater {
                model: Config.bar.right
                ModuleWrapper {
                    source: "modules/" + modelData.module + ".qml"
                    active: modelData.enabled && modelData.module !== "TrayToggle"
                }
            }
        ]
    }
}