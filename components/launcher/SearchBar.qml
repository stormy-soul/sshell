import QtQuick
import "../../theme"
import "../../services"
import "../common"

Row {
    id: root
    spacing: Theme.padding
    
    property alias searchText: searchInput.text
    
    signal accepted()
    
    function focusInput() {
        searchInput.forceActiveFocus()
    }
    
    // Icon that changes based on search mode
    MaterialSymbol {
        anchors.verticalCenter: parent.verticalCenter
        size: Theme.fontSizeLarge
        color: Theme.accent
        text: {
            if (LauncherSearch.searchMode === 1) return "apps"
            if (LauncherSearch.searchMode === 2) return "calculate"
            return "search"
        }
        fill: 1
    }
    
    // Search input
    Rectangle {
        width: 400
        height: 40
        radius: Theme.cornerRadiusSmall
        color: Theme.surface
        border.color: searchInput.activeFocus ? Theme.accent : Theme.border
        border.width: 1
        
        Behavior on width {
            enabled: searchInput.text !== ""
            NumberAnimation {
                duration: Theme.animationDuration
                easing.type: Easing.OutCubic
            }
        }
        
        TextInput {
            id: searchInput
            anchors.fill: parent
            anchors.margins: Theme.padding
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSize
            color: Theme.text
            verticalAlignment: TextInput.AlignVCenter
            selectByMouse: true
            focus: true
            
            onTextChanged: {
                LauncherSearch.query = text
            }
            
            onAccepted: root.accepted()
            
            Text {
                visible: parent.text.length === 0
                text: "Search apps, calculate..."
                font: parent.font
                color: Theme.textSecondary
                anchors.verticalCenter: parent.verticalCenter
            }
        }
    }
}
