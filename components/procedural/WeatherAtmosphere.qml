import QtQuick
import Qt5Compat.GraphicalEffects

Item {
    id: root
    anchors.fill: parent

    property string condition: "clear"

    visible: condition === "fog" || condition === "snow" || condition === "storm"

    // Solid fog overlay — grayish, not white
    Rectangle {
        anchors.fill: parent
        color: "#9E9E9E"
        opacity: {
            if (root.condition === "fog") return 0.35
            if (root.condition === "snow") return 0.15
            if (root.condition === "storm") return 0.10
            return 0
        }
        Behavior on opacity { NumberAnimation { duration: 2000 } }
    }

    // Noise grain for texture
    Image {
        anchors.fill: parent
        source: "noise/noise_mid.png"
        fillMode: Image.Tile
        opacity: root.condition === "fog" ? 0.20 : 0.06
        visible: true
        layer.enabled: true
        layer.effect: ColorOverlay {
            color: "#B0B0B0"
        }
        Behavior on opacity { NumberAnimation { duration: 2000 } }
    }
}
