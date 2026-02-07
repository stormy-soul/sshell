import QtQuick
import QtQuick.Controls
import "../../settings"

/**
 * Material 3 switch. See https://m3.material.io/components/switch/overview
 */
Switch {
    id: root
    property real scale: 0.75 // Default in m3 spec is huge af
    implicitHeight: 32 * root.scale
    implicitWidth: 52 * root.scale
    property color activeColor: Appearance.colors.primary
    property color inactiveColor: Appearance.colors.surfaceVariant

    PointingHandInteraction {}

    background: Rectangle {
        width: parent.width
        height: parent.height
        radius: 9999
        color: root.checked ? root.activeColor : root.inactiveColor
        border.width: 2 * root.scale
        border.color: root.checked ? root.activeColor : Appearance.colors.outline

        Behavior on color {
            ColorAnimation { duration: Appearance.animation.durationFast }
        }
        Behavior on border.color {
            ColorAnimation { duration: Appearance.animation.durationFast }
        }
    }

    indicator: Rectangle {
        width: (root.pressed || root.down) ? (28 * root.scale) : root.checked ? (24 * root.scale) : (16 * root.scale)
        height: (root.pressed || root.down) ? (28 * root.scale) : root.checked ? (24 * root.scale) : (16 * root.scale)
        radius: 9999
        color: root.checked ? Appearance.colors.colOnPrimary : Appearance.colors.outline
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        anchors.leftMargin: root.checked ? ((root.pressed || root.down) ? (22 * root.scale) : 24 * root.scale) : ((root.pressed || root.down) ? (2 * root.scale) : 8 * root.scale)

        Behavior on anchors.leftMargin {
            NumberAnimation {
                duration: Appearance.animation.duration
                easing.type: Appearance.animation.easingSmooth
            }
        }
        Behavior on width {
            NumberAnimation {
                duration: Appearance.animation.duration
                easing.type: Appearance.animation.easingSmooth
            }
        }
        Behavior on height {
            NumberAnimation {
                duration: Appearance.animation.duration
                easing.type: Appearance.animation.easingSmooth
            }
        }
        Behavior on color {
            ColorAnimation { duration: Appearance.animation.durationFast }
        }
    }
}
