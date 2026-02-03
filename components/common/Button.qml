import QtQuick
import QtQuick.Controls
import "../../settings"

Button {
    id: control
    
    leftPadding: 16
    rightPadding: 16
    
    contentItem: Text {
        text: control.text
        font: control.font
        opacity: enabled ? 1.0 : 0.3
        color: Appearance.colors.text
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        elide: Text.ElideRight
    }

    background: Rectangle {
        implicitWidth: 100
        implicitHeight: 40
        color: control.down ? Appearance.colors.surfaceVariant : Appearance.colors.surface
        border.color: Appearance.colors.border
        border.width: 1
        radius: Appearance.sizes.cornerRadius
    }
}
