import QtQuick
import "../../settings"
import "../../services"
import "../common"

Item {
    id: root
    focus: true
    
    function focusSearchInput() {
        searchBar.focusInput()
    }
    
    MouseArea {
        anchors.fill: parent
        onClicked: {
            ModuleLoader.launcherVisible = false
        }
    }
    
    Rectangle {
        id: searchWidget
        anchors {
            horizontalCenter: parent.horizontalCenter
            top: parent.top
            topMargin: Appearance.sizes.paddingLarge
        }
        
        implicitWidth: contentColumn.width + (showResults ? Appearance.sizes.paddingLarge * 2 : 0)
        implicitHeight: searchBar.height + (showResults ? separator.height + resultsList.height + Appearance.sizes.paddingLarge * 2 : 0)
        
        readonly property bool showResults: LauncherSearch.query !== ""
        
        color: Appearance.colors.background
        radius: searchBar.height / 2
        border.color: Appearance.colors.border
        border.width: 1
        
        Behavior on implicitHeight {
            NumberAnimation {
                duration: Appearance.animation.duration
                easing.type: Appearance.animation.easingDefault
            }
        }
        
        Column {
            id: contentColumn
            anchors {
                top: parent.top
                horizontalCenter: parent.horizontalCenter
                topMargin: searchWidget.showResults ? Appearance.sizes.paddingLarge : 0
                bottomMargin: searchWidget.showResults ? Appearance.sizes.paddingLarge : 0
            }
            width: Appearance.sizes.searchBarWidth + Appearance.sizes.paddingLarge * 2
            spacing: Appearance.sizes.padding
            
            SearchBar {
                id: searchBar
                width: parent.width
                resultsList: resultsList
                
                onAccepted: {
                    if (LauncherSearch.results.length > 0) {
                        var firstResult = LauncherSearch.results[0]
                        if (firstResult.execute) {
                            firstResult.execute()
                            ModuleLoader.launcherVisible = false
                        }
                    }
                }
            }
            
            Rectangle {
                id: separator
                width: parent.width
                height: 1
                color: Appearance.colors.border
                visible: searchWidget.showResults
            }
            
            ListView {
                id: resultsList
                width: parent.width
                height: contentHeight > Appearance.sizes.resultListMaxHeight ? Appearance.sizes.resultListMaxHeight : contentHeight
                clip: contentHeight > Appearance.sizes.resultListMaxHeight
                spacing: Appearance.sizes.paddingSmall
                visible: searchWidget.showResults
                topMargin: Appearance.sizes.paddingSmall
                bottomMargin: Appearance.sizes.paddingSmall
                
                model: LauncherSearch.results
                currentIndex: 0
                highlightFollowsCurrentItem: true
                keyNavigationEnabled: true
                focus: true
                
                Keys.onUpPressed: {
                    if (currentIndex > 0) {
                        currentIndex--
                    } else {
                        searchBar.focusInput()
                    }
                }
                
                Keys.onDownPressed: {
                    if (currentIndex < count - 1) {
                        currentIndex++
                    }
                }
                
                Keys.onReturnPressed: {
                    if (currentIndex >= 0 && currentIndex < count) {
                        var currentItem = LauncherSearch.results[currentIndex]
                        if (currentItem && currentItem.execute) {
                            currentItem.execute()
                            ModuleLoader.launcherVisible = false
                        }
                    }
                }
                
                delegate: SearchItem {
                    required property var modelData
                    required property int index
                    entry: modelData
                    highlighted: ListView.isCurrentItem
                }
                
                Text {
                    visible: resultsList.count === 0 && LauncherSearch.query !== ""
                    anchors.centerIn: parent
                    text: "No results found"
                    font.family: Appearance.font.family.main
                    font.pixelSize: Appearance.font.pixelSize.normal
                    color: Appearance.colors.textSecondary
                }
            }
        }
    }
}