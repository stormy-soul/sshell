import QtQuick
import QtQuick.Effects

Item {
    id: root
    anchors.fill: parent
    
    property string condition: "clear"
    property string timeOfDay: "day"

    visible: (condition === "clear" || condition === "cloudy")
    
    Rectangle {
        id: glow
        width: 150
        height: 150
        radius: 75
        color: root.timeOfDay === "day" ? "#FFD54F" : "#E0E0E0"
        

        x: parent.width * 0.7
        y: parent.height * 0.15
        
        opacity: {
            if (root.condition === "cloudy") return 0.3
            return 0.8
        }
        
        layer.enabled: true
        layer.effect: MultiEffect {
            blurEnabled: true
            blurMax: 64
            blur: 1.0
        }
    }
}
