import QtQuick
import QtQuick.Controls

import "../../settings"

Slider {
    id: control
        
    background: Rectangle {
        x: control.leftPadding
        y: control.topPadding + control.availableHeight / 2 - height / 2
        implicitWidth: 200
        implicitHeight: 6
        width: control.availableWidth
        height: implicitHeight
        radius: 3
        color: Appearance.colors.surfaceVariant
        
        Rectangle {
            width: control.visualPosition * parent.width
            height: parent.height
            color: Appearance.colors.accent
            radius: 3
        }
    }
    
    handle: Rectangle {
        x: control.leftPadding + control.visualPosition * (control.availableWidth - width)
        y: control.topPadding + control.availableHeight / 2 - height / 2
        implicitWidth: 16 
        implicitHeight: 16
        radius: 8
        color: Appearance.colors.accent
        border.color: Appearance.colors.surface
        border.width: 1
    }
}
