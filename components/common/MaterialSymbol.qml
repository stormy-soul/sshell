import QtQuick
import "../../settings"

Text {
    id: root
    
    property int size: 24
    property real fill: 0
    property real weight: 400
    property real grade: 0
    
    font.family: Appearance.font.family.iconMaterial
    font.pixelSize: size
    font.weight: Font.Normal
    color: Appearance.colors.text
    
    font.variableAxes: {
        "FILL": fill,
        "wght": weight,
        "GRAD": grade,
        "opsz": size
    }
    
    renderType: Text.NativeRendering
    
    Behavior on fill {
        NumberAnimation {
            duration: Appearance.animation.duration
            easing.type: Easing.InOutQuad
        }
    }
}
