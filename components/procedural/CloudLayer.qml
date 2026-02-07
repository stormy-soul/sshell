import QtQuick
import Qt5Compat.GraphicalEffects

Item {
    id: root
    anchors.fill: parent
    
    property string condition: "clear"
    property string timeOfDay: "day"

    readonly property real density: {
         if (condition === "clear") return 0.0
         if (condition === "cloudy") return 0.8
         if (condition === "rain") return 0.9
         if (condition === "storm") return 1.0
         if (condition === "snow") return 0.6
         if (condition === "fog") return 0.4
         return 0.0
    }

    Item {
        id: cloudContainer
        anchors.fill: parent
        visible: root.density > 0.05
        opacity: root.density * 0.4 
        
        Image {
            id: cloudImg
            source: "noise/noise_low.png"
            sourceSize.width: 512
            sourceSize.height: 512

            width: parent.width * 2
            height: parent.height
            fillMode: Image.Tile
            smooth: true

            NumberAnimation on x {
                from: 0
                to: -parent.width / 2
                duration: 80000 
                loops: Animation.Infinite
                running: true
            }
        }
        
        Image {
            source: "noise/noise_low.png"
            sourceSize.width: 350
            sourceSize.height: 350
            
            width: parent.width * 2
            height: parent.height
            fillMode: Image.Tile
            smooth: true
            opacity: 0.5 
            
            NumberAnimation on x {
                from: 0
                to: -parent.width / 2
                duration: 45000 
                loops: Animation.Infinite
                running: true
            }
        }
        
        layer.enabled: true
        layer.effect: OpacityMask {
            maskSource: LinearGradient {
                width: cloudContainer.width
                height: cloudContainer.height
                start: Qt.point(0, 0)
                end: Qt.point(0, height)
                gradient: Gradient {
                    GradientStop { position: 0.0; color: "black" } 
                    GradientStop { position: 0.6; color: "black" } 
                    GradientStop { position: 1.0; color: "transparent" } 
                }
            }
        }
    }
}
