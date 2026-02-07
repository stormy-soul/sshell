import QtQuick
import "../../../settings"
import "../../common"
import Quickshell.Services.SystemTray

Rectangle {
    id: root
    implicitWidth: 30
    implicitHeight: Config.bar.height - Appearance.sizes.padding
    color: "transparent"
    radius: Appearance.sizes.cornerRadiusSmall
    
    property bool isTrayEnabled: {
        var rightModules = Config.bar.right;
        for (var i = 0; i < rightModules.length; i++) {
            if (rightModules[i].module === "Tray" && rightModules[i].enabled) {
                return true;
            }
        }
        return false;
    }
    
    visible: isTrayEnabled && SystemTray.items.values.length > 0
    
    property real globalCenterX: 0
    
    function updatePosition() {
        var p = mapToItem(null, width / 2, 0);
        if (p) {
            globalCenterX = p.x;
        }
    }
    
    Timer {
        interval: 100
        running: true
        repeat: true // Check periodically in case of bar resize
        onTriggered: parent.updatePosition()
    }
    
    onXChanged: updatePosition()
    onWidthChanged: updatePosition()
    Component.onCompleted: updatePosition()
    
    Loader {
        id: trayPopupLoader
        active: false
        source: "popups/TrayPopup.qml"
        onLoaded: {
             item.sourceCenter = Qt.binding(function() { return root.globalCenterX })
        }
    }

    MaterialIcon {
        anchors.centerIn: parent
        icon: "expand_more"
        width: Appearance.font.pixelSize.huge
        height: Appearance.font.pixelSize.huge
        color: Appearance.colors.text
        rotation: trayPopupLoader.item && trayPopupLoader.item.shown ? 180 : 0
        
        Behavior on rotation {
            NumberAnimation { duration: Appearance.animation.duration }
        }
    }
    
    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onEntered: root.color = Appearance.colors.surfaceHover
        onExited: root.color = "transparent"
        onClicked: {
             if (!trayPopupLoader.active) {
                 trayPopupLoader.active = true
             }
             if (trayPopupLoader.item) {
                 trayPopupLoader.item.shown = !trayPopupLoader.item.shown
             }
        }
    }
}
