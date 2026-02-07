import QtQuick
import Qt5Compat.GraphicalEffects

Item {
    id: root
    anchors.fill: parent
    
    property string condition: "clear"
    
    visible: condition === "fog" || condition === "snow" || condition === "storm"

    Image {
        id: grainSource
        anchors.fill: parent
        source: "noise/noise_mid.png"
        fillMode: Image.Tile
        smooth: true
        visible: false
    }
    
    Image {
        id: visualGrain
        anchors.fill: parent
        source: "noise/noise_mid.png"
        fillMode: Image.Tile
        opacity: root.condition === "fog" ? 0.15 : 0.05 
        visible: true
        layer.enabled: true
        layer.effect: ColorOverlay {
            color: "#FFFFFF"
        }
    }
}
