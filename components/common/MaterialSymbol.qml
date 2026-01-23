import QtQuick
import "../../theme"

Text {
    id: root
    
    property int size: 24
    property real fill: 0 // 0 = outlined, 1 = filled
    property real weight: 400
    property real grade: 0
    
    font.family: "Material Symbols Rounded"
    font.pixelSize: size
    font.weight: Font.Normal
    color: Theme.text
    
    // Material Symbols variable font axes
    font.variableAxes: {
        "FILL": fill,
        "wght": weight,
        "GRAD": grade,
        "opsz": size
    }
    
    renderType: Text.NativeRendering
    
    Behavior on fill {
        NumberAnimation {
            duration: Theme.animationDuration
            easing.type: Easing.InOutQuad
        }
    }
}
