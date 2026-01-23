import QtQuick
import "../../services"
import "../../theme"
import "../common"
import "../bar"

Rectangle {
    id: launcher
    color: Theme.background
    radius: Theme.cornerRadiusSmall
    border.color: Theme.border
    border.width: 1
    
    implicitWidth: Config.launcher.width
    implicitHeight: searchBar.height + (showResults ? resultsList.height + Theme.paddingLarge * 2 : Theme.paddingLarge * 2)
    
    readonly property bool showResults: LauncherSearch.query !== ""
    
    Behavior on implicitHeight {
        NumberAnimation {
            duration: Theme.animationDuration
            easing.type: Easing.OutCubic
        }
    }
    
    Column {
        anchors.fill: parent
        anchors.margins: Theme.paddingLarge
        spacing: Theme.padding
        
        // Search bar
        SearchBar {
            id: searchBar
            width: parent.width
            
            Component.onCompleted: {
                focusInput()
            }
            
            onAccepted: {
                // Launch first result if available
                if (LauncherSearch.results.length > 0) {
                    var firstResult = LauncherSearch.results[0]
                    if (firstResult.execute) {
                        firstResult.execute()
                        ModuleLoader.launcherVisible = false
                    }
                }
            }
        }
        
        // Separator
        Rectangle {
            width: parent.width
            height: 1
            color: Theme.border
            visible: showResults
        }
        
        // Results list
        ListView {
            id: resultsList
            width: parent.width
            height: Math.min(400, contentHeight)
            clip: true
            spacing: Theme.paddingSmall
            visible: showResults
            
            model: LauncherSearch.results
            
            delegate: SearchItem {
                entry: (typeof modelData !== "undefined") ? modelData : null
            }
            
            // Empty state
            Text {
                visible: resultsList.count === 0 && LauncherSearch.query !== ""
                anchors.centerIn: parent
                text: "No results found"
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSize
                color: Theme.textSecondary
            }
        }
    }
    
    // Close on Escape
    Keys.onEscapePressed: {
        if (LauncherSearch.query !== "") {
            LauncherSearch.query = ""
        } else {
            ModuleLoader.launcherVisible = false
        }
    }
}