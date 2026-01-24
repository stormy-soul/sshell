import QtQuick
import "../common"
import "../../settings"
import "../../services"

Row {
    id: root
    spacing: Appearance.sizes.padding
    leftPadding: Appearance.sizes.paddingLarge
    rightPadding: Appearance.sizes.paddingSmall
    
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
    
    // Search icon with Material shape
    MaterialShapeWrappedIcon {
        anchors.verticalCenter: parent.verticalCenter
        iconSize: Appearance.font.pixelSize.huge
        iconColor: Appearance.colors.iconShapeFg
        shapeColor: Appearance.colors.iconShapeBg
        padding: 8
        text: {
            if (LauncherSearch.searchMode === 1) return "apps"
            if (LauncherSearch.searchMode === 2) return "calculate"
            return "search"
        }
        shape: {
            if (LauncherSearch.searchMode === 1) return MaterialShape.Shape.Clover4Leaf
            if (LauncherSearch.searchMode === 2) return MaterialShape.Shape.PuffyDiamond
            return MaterialShape.Shape.Cookie7Sided
        }
    }
    
    // Search input with darker background
    Rectangle {
        width: Appearance.sizes.searchBarWidth
        height: Appearance.sizes.searchBarHeight
        anchors.verticalCenter: parent.verticalCenter
        radius: height / 2
        color: Appearance.colors.inputBackground
        
        TextInput {
            id: searchInput
            anchors.fill: parent
            anchors.leftMargin: Appearance.sizes.paddingLarge
            anchors.rightMargin: Appearance.sizes.paddingLarge
            font.family: Appearance.font.family.main
            font.pixelSize: Appearance.font.pixelSize.normal
            color: Appearance.colors.text
            verticalAlignment: TextInput.AlignVCenter
            selectByMouse: true
            focus: true
            clip: true
            
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
