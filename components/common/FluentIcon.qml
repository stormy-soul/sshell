import QtQuick
import Qt5Compat.GraphicalEffects
import Quickshell
import "../../settings"

Item {
    id: root
    property string icon: ""
    property color color: Appearance.colors.text
    
    implicitWidth: 24
    implicitHeight: 24
    
    Image {
        id: iconImage
        anchors.fill: parent
        source: {
            if (!root.icon) return ""
            return Quickshell.shellPath("assets/icons/fluent/" + root.icon + ".svg")
        }
        sourceSize.width: width
        sourceSize.height: height
        visible: false
        smooth: true
        mipmap: true
        fillMode: Image.PreserveAspectFit
    }
    
    ColorOverlay {
        id: overlay
        anchors.fill: iconImage
        source: iconImage
        color: root.color
    }
}
