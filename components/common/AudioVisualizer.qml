import QtQuick
import Qt5Compat.GraphicalEffects
import "../../settings"
import "../../services"

Item {
    id: root
    
    implicitWidth: (barWidth * 6) + (barGap * 5)
    implicitHeight: maxBarHeight
    
    property int barWidth: 3
    property int barGap: 2
    property int maxBarHeight: 20
    property int minBarHeight: 4
    property color barColor: Appearance.colors.accent
    property int animationDuration: 35
    property bool onBar: true
    
    property string source: ""
    
    property var values: CavaService.values
    
    visible: CavaService.running && CavaService.available
    
    Item {
        id: gradientSource
        anchors.fill: parent
        visible: false
        
        Image {
            id: coverArtObj
            anchors.fill: parent
            source: root.source
            sourceSize.width: 100 
            sourceSize.height: 100
            fillMode: Image.PreserveAspectCrop
            visible: false
        }
        
        FastBlur {
            id: blur
            anchors.fill: coverArtObj
            source: coverArtObj
            radius: 32
            transparentBorder: true
            visible: false
        }
        
        LevelAdjust {
            id: levels
            anchors.fill: blur
            source: blur
            minimumOutput: root.onBar ? "#454545" : "#252525"
        }
        
        BrightnessContrast {
            anchors.fill: levels
            source: levels
            brightness: root.onBar ? 0.1 : 0.0
            contrast: root.onBar ? 0.1 : 0.15
        }
        
        Rectangle {
            anchors.fill: parent
            color: root.barColor
            visible: root.source === ""
        }
    }
    
    Item {
        id: maskItem
        anchors.fill: parent
        visible: false
        
        Row {
            id: barRow
            anchors.centerIn: parent
            height: parent.height
            spacing: root.barGap
            
            Repeater {
                model: [2, 1, 0, 3, 4, 5]
                
                Rectangle {
                    width: root.barWidth
                    height: Math.max(root.minBarHeight, root.values[modelData] * root.maxBarHeight)
                    radius: root.barWidth / 2
                    color: "white" 
                    anchors.verticalCenter: parent.verticalCenter
                    
                    Behavior on height {
                        NumberAnimation {
                            duration: root.animationDuration
                            easing.type: Easing.OutQuad
                        }
                    }
                }
            }
        }
    }
    
    OpacityMask {
        anchors.fill: maskItem
        source: gradientSource
        maskSource: maskItem
    }
}
