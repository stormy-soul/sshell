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
            topMargin: Appearance.sizes.elevationMargin
        }
        
        readonly property bool showResults: LauncherSearch.query !== ""

        implicitWidth: (contentColumn.width || 400) + Appearance.sizes.paddingLarge * 2
        implicitHeight: {
            if (showResults) {
                return contentColumn.implicitHeight + Appearance.sizes.paddingLarge * 2
            } else {
                var minH = Appearance.sizes.launcherInitialHeight || 300
                var barH = (searchBar.height || 40) + (Appearance.sizes.paddingLarge * 2)
                return Math.max(minH, barH)
            }
        }
        
        color: Qt.rgba(
            Appearance.colors.background.r,
            Appearance.colors.background.g,
            Appearance.colors.background.b,
            0.85
        )
        radius: Appearance.sizes.searchBarHeight / 2 + Appearance.sizes.paddingLarge
        border.color: Appearance.colors.border
        border.width: 1
        clip: true
        
        Behavior on implicitHeight {
            NumberAnimation {
                duration: Appearance.animation.duration
                easing.type: Appearance.animation.easingDefault
            }
        }
        
        Column {
            id: contentColumn
            anchors.centerIn: parent
            
            width: searchBar.implicitWidth || Appearance.sizes.searchBarWidth || 400
            spacing: Appearance.sizes.padding
            
            SearchBar {
                id: searchBar
                resultsList: resultsList
                
                height: Appearance.sizes.searchBarHeight || 40
                width: parent.width
                
                onAccepted: {
                    if (LauncherSearch.results.length > 0) {
                        var firstResult = LauncherSearch.results[0]
                        if (firstResult && firstResult.execute) {
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
                height: Math.min(
                    contentHeight + topMargin + bottomMargin,
                    Appearance.sizes.resultListMaxHeight
                )
                
                clip: true
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
                    if (currentIndex > 0) currentIndex--
                    else searchBar.focusInput()
                }
                Keys.onDownPressed: {
                    if (currentIndex < count - 1) currentIndex++
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
                    width: resultsList.width
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