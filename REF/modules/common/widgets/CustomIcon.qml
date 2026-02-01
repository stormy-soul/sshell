import QtQuick
import Quickshell
import Quickshell.Widgets
import Qt5Compat.GraphicalEffects

Item {
    id: root
    
    property bool colorize: false
    property color color
    property string source: ""
    property string iconFolder: Qt.resolvedUrl(Quickshell.shellPath("assets/icons"))  // The folder to check first
    property real push: 0
    property string side: "top"
    width: 30
    height: 30
    
    IconImage {
        id: iconImage
        source: {
            const fullPathWhenSourceIsIconName = iconFolder + "/" + root.source;
            if (iconFolder && fullPathWhenSourceIsIconName) {
                return fullPathWhenSourceIsIconName
            }
            return root.source
        }
        implicitSize: root.height

        anchors {
            fill: parent
            topMargin: root.side === "top" ? root.push : 0
            bottomMargin: root.side === "bottom" ? root.push : 0
            leftMargin: root.side === "left" ? root.push : 0
            rightMargin: root.side === "right" ? root.push : 0
        }
    }

    Loader {
        active: root.colorize
        anchors.fill: iconImage
        sourceComponent: ColorOverlay {
            source: iconImage
            color: root.color
        }
    }
}
