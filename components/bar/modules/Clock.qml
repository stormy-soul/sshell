import QtQuick

import "../../../services"
import "../../../theme"

Rectangle {
    id: clockModule
    width: timeText.width + Theme.padding * 2
    height: parent.height - Theme.paddingSmall
    radius: Theme.cornerRadiusSmall
    color: "transparent"
    
    property string timeFormat: "hh:mm"
    property string dateFormat: "MMM dd"
    
    Timer {
        interval: 1000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            let now = new Date()
            timeText.text = Qt.formatTime(now, clockModule.timeFormat)
            dateText.text = Qt.formatDate(now, clockModule.dateFormat)
        }
    }
    
    Column {
        anchors.centerIn: parent
        spacing: 0
        
        Text {
            id: timeText
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSize
            font.weight: Font.Medium
            color: Theme.text
            horizontalAlignment: Text.AlignHCenter
        }
        
        Text {
            id: dateText
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSizeSmall
            color: Theme.textSecondary
            horizontalAlignment: Text.AlignHCenter
        }
    }
    
    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        
        onEntered: parent.color = Theme.surfaceVariant
        onExited: parent.color = "transparent"
    }
}