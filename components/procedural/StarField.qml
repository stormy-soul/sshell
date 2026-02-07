import QtQuick

Item {
    id: root
    anchors.fill: parent
    
    property string timeOfDay: "night"
    property string condition: "clear"
    
    visible: timeOfDay === "night" && (condition === "clear" || condition === "cloudy")
    opacity: condition === "cloudy" ? 0.3 : 1.0

    Repeater {
        model: 60
        Rectangle {
            property real size: Math.random() * 2 + 1
            width: size
            height: size
            radius: size / 2
            color: "#FFFFFF"
            x: Math.random() * root.width
            y: Math.random() * root.height * 0.7 
            opacity: Math.random() * 0.7 + 0.3
            
            SequentialAnimation on opacity {
                loops: Animation.Infinite
                running: true
                NumberAnimation { to: 0.2; duration: Math.random() * 2000 + 1000 }
                NumberAnimation { to: 1.0; duration: Math.random() * 2000 + 1000 }
            }
        }
    }
}
