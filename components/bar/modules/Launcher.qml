import QtQuick
import Qt5Compat.GraphicalEffects
import "../../../settings"
import "../../../services"
import "../../common"

Rectangle {
    id: launcherButton
    implicitWidth: iconItem.width
    implicitHeight: Config.bar.height
    color: "transparent"
    radius: Appearance.sizes.cornerRadiusSmall
    
    Item {
        id: iconItem
        anchors.centerIn: parent
        width: 18 + Appearance.sizes.padding * 2
        height: 18
        
        property string iconSource: {
             var path = SystemInfo.osIconPath
             // We can't synchronously check existence easily, but we can handle error
             return path
        }
        
        Image {
            id: img
            anchors.fill: parent
            source: parent.iconSource
            sourceSize.width: width
            sourceSize.height: height
            visible: false
            smooth: true
            mipmap: true
            fillMode: Image.PreserveAspectFit
            
            onStatusChanged: {
                if (status === Image.Error) {
                    source = Quickshell.shellPath("assets/icons/linux-symbolic.svg")
                }
            }
        }
        
        ColorOverlay {
            anchors.fill: img
            source: img
            color: hoverArea.containsMouse ? Appearance.colors.accent : Appearance.colors.text
            visible: img.status === Image.Ready
        }
    }
    
    MouseArea {
        id: hoverArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        
        onClicked: {
            ModuleLoader.launcherVisible = !ModuleLoader.launcherVisible
        }
    }
}