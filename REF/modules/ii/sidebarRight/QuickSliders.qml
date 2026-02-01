import qs
import qs.services
import qs.modules.common
import qs.modules.common.widgets
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import Quickshell.Services.UPower

Rectangle {
    id: root

    property var screen: root.QsWindow.window?.screen
    property var brightnessMonitor: Brightness.getMonitorForScreen(screen)

    implicitWidth: contentItem.implicitWidth + root.horizontalPadding * 2
    implicitHeight: contentItem.implicitHeight + root.verticalPadding * 2
    radius: Appearance.rounding.normal
    color: Appearance.colors.colLayer1
    property real verticalPadding: 4
    property real horizontalPadding: 12

    Column {
        id: contentItem
        anchors {
            fill: parent
            leftMargin: root.horizontalPadding
            rightMargin: root.horizontalPadding
            topMargin: root.verticalPadding
            bottomMargin: root.verticalPadding
        }

        Loader {
            anchors {
                left: parent.left
                right: parent.right
            }
            visible: active
            active: Config.options.sidebar.quickSliders.showBrightness
            sourceComponent: QuickSlider {
                materialSymbol: "brightness_6"
                value: root.brightnessMonitor.brightness
                onMoved: {
                    root.brightnessMonitor.setBrightness(value)
                }
            }
        }

        Loader {
            anchors {
                left: parent.left
                right: parent.right
            }
            visible: active
            active: Config.options.sidebar.quickSliders.showVolume
            sourceComponent: QuickSlider {
                materialSymbol: "volume_up"
                value: Audio.sink.audio.volume
                onMoved: {
                    Audio.sink.audio.volume = value
                }
            }
        }

        Loader {
            anchors {
                left: parent.left
                right: parent.right
            }
            visible: active
            active: Config.options.sidebar.quickSliders.showMic
            sourceComponent: QuickSlider {
                materialSymbol: "mic"
                value: Audio.source.audio.volume
                onMoved: {
                    Audio.source.audio.volume = value
                }
            }
        }
    }

    component QuickSlider: RowLayout { 
        id: quickSlider

        required property string materialSymbol
        property real value
        signal moved(real value)

        spacing: 10
        Layout.fillWidth: true 

        StyledSlider {
            id: slider
            Layout.fillWidth: true 

            configuration: StyledSlider.Configuration.XS
            stopIndicatorValues: []

            value: quickSlider.value
            onMoved: quickSlider.moved(value)
        }
        
        MaterialSymbol {
            id: icon
            Layout.alignment: Qt.AlignVCenter
            property bool nearFull: quickSlider.value >= 0.9

            iconSize: 20
            color: nearFull ? Appearance.colors.colOnLayer0 : Appearance.colors.colOnLayer1
            text: quickSlider.materialSymbol

            Behavior on color {
                animation: Appearance.animation.elementMoveFast.colorAnimation.createObject(this)
            }
        }
    }
}
