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
    
    MaterialShapeWrappedIcon {
        anchors.verticalCenter: parent.verticalCenter
        iconSize: Appearance.font.pixelSize.huge
        iconColor: Appearance.colors.iconShapeFg
        shapeColor: Appearance.colors.iconShapeBg
        padding: 8
        text: {
            if (LauncherSearch.searchMode === 1) return "apps"
            if (LauncherSearch.searchMode === 2) return "calculate"
            if (LauncherSearch.searchMode === 3) return "content_paste"
            return "search"
        }
        shape: {
            if (LauncherSearch.searchMode === 1) return MaterialShape.Shape.Gem
            if (LauncherSearch.searchMode === 2) return MaterialShape.Shape.Cookie6Sided
            if (LauncherSearch.searchMode === 3) return MaterialShape.Shape.Cookie7Sided
            return MaterialShape.Shape.Cookie7Sided
        }
    }
    
    Rectangle {
        width: searchInput.text.length > 0 ? Appearance.sizes.searchBarWidth : Appearance.sizes.searchBarWidthShort
        Behavior on width { NumberAnimation { duration: 300; easing.type: Easing.OutCubic } }
        
        height: Appearance.sizes.searchBarHeight
        anchors.verticalCenter: parent.verticalCenter
        radius: height / 2
        color: "transparent"
        
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
                text: "Search for apps, calculate, or clipboard..."
                font: parent.font
                color: Appearance.colors.textSecondary
                anchors.verticalCenter: parent.verticalCenter
            }
        }
    }
}
