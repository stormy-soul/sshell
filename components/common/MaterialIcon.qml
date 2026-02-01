import QtQuick
import Qt5Compat.GraphicalEffects
import Quickshell
import "../../settings"

Item {
    id: root
    property string icon: ""
    property color color: Appearance.colors.text
    property string type: Config.theme.icons

    implicitWidth: 24
    implicitHeight: 24

    Image {
        id: iconImage
        anchors.fill: parent
        source: {
            if (!root.icon) return ""
            var p = Quickshell.shellPath("assets/material-design-icons/svg/" + root.type + "/" + root.icon + ".svg")
            return p
        }
        sourceSize.width: width
        sourceSize.height: height
        visible: false
        smooth: true
        mipmap: true
        fillMode: Image.PreserveAspectFit
        
        onStatusChanged: {
            if (status === Image.Error) {
                console.warn("MaterialIcon: Failed to load icon: " + source)
            }
            if (status === Image.Ready) {
               // console.log("MaterialIcon: Loaded " + source)
            }
        }
    }

    ColorOverlay {
        id: overlay
        anchors.fill: iconImage
        source: iconImage
        color: root.color
        visible: iconImage.status === Image.Ready
    }
}
