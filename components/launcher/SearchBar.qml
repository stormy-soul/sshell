import QtQuick
import "../../components"
import "../../settings"
import "../../services"

Row {
    id: root
    spacing: Appearance.sizes.padding
    leftPadding: Appearance.sizes.paddingLarge
    
    property alias searchText: searchInput.text
    property ListView resultsList: null  
    
    signal accepted()
    
    function focusInput() {
        searchInput.forceActiveFocus()
    }
    
    Keys.onDownPressed: {
        if (resultsList && resultsList.count > 0) {
            resultsList.forceActiveFocus()
            resultsList.currentIndex = 0
        }
    }
    
    MaterialSymbol {
        anchors.verticalCenter: parent.verticalCenter
        size: Appearance.sizes.searchIconSize
        color: Appearance.colors.accent
        text: {
            if (LauncherSearch.searchMode === 1) return "apps"
            if (LauncherSearch.searchMode === 2) return "calculate"
            return "search"
        }
        fill: 1
    }
    
    Rectangle {
        width: Appearance.sizes.searchBarWidth
        height: Appearance.sizes.searchBarHeight
        radius: Appearance.sizes.searchBarRadius
        color: "transparent"
        border.width: 0
        
        TextInput {
            id: searchInput
            anchors.fill: parent
            anchors.rightMargin: Appearance.sizes.paddingLarge
            font.family: Appearance.font.family.main
            font.pixelSize: Appearance.font.pixelSize.normal
            color: Appearance.colors.text
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
                color: Appearance.colors.textSecondary
                anchors.verticalCenter: parent.verticalCenter
            }
        }
    }
}
