import QtQuick
import Quickshell.Io

import "../../services"
import "../../theme"
import "../common"

Rectangle {
    id: launcher
    color: Theme.background
    radius: Theme.cornerRadius
    border.color: Theme.border
    border.width: 1

    signal launchApp

    // Filtered model for search
    property var filteredApps: []
    property string searchQuery: searchInput.text.toLowerCase()

    onSearchQueryChanged: filterApps()

    Component.onCompleted: {
        // Initial filter (show all)
        filterApps()
        
        // Connect to AppService changes
        AppService.apps.countChanged.connect(filterApps)
    }

    function filterApps() {
        var query = searchQuery.trim()
        var apps = []
        
        for (var i = 0; i < AppService.apps.count; i++) {
            var app = AppService.apps.get(i)
            apps.push({
                name: app.name,
                icon: app.icon,
                exec: app.exec,
                description: app.description,
                score: 0
            })
        }
        
        if (query.length === 0) {
            // No search, show all apps in alphabetical order
            filteredApps = apps
            appListModel.clear()
            for (var j = 0; j < apps.length; j++) {
                appListModel.append(apps[j])
            }
            return
        }
        
        // Apply search filtering
        var matched = []
        var unmatched = []
        
        for (var k = 0; k < apps.length; k++) {
            var app = apps[k]
            var score = 0
            
            if (Config.launcher.fuzzy) {
                score = fuzzyMatch(query, app.name.toLowerCase())
            } else {
                // Simple substring search
                if (app.name.toLowerCase().includes(query)) {
                    score = 100 - app.name.toLowerCase().indexOf(query)
                }
            }
            
            if (score > 0) {
                app.score = score
                matched.push(app)
            } else {
                unmatched.push(app)
            }
        }
        
        // Sort matched by score (highest first)
        matched.sort(function(a, b) { return b.score - a.score })
        
        // Combine: matched first, then unmatched
        filteredApps = matched.concat(unmatched)
        
        appListModel.clear()
        for (var m = 0; m < filteredApps.length; m++) {
            appListModel.append(filteredApps[m])
        }
    }
    
    // Fuzzy matching algorithm
    function fuzzyMatch(query, text) {
        var queryIndex = 0
        var score = 0
        var consecutive = 0
        
        for (var i = 0; i < text.length && queryIndex < query.length; i++) {
            if (text[i] === query[queryIndex]) {
                queryIndex++
                consecutive++
                score += consecutive * 10  // Bonus for consecutive matches
            } else {
                consecutive = 0
            }
        }
        
        // Return score only if all query characters were matched
        if (queryIndex === query.length) {
            // Bonus if match starts at beginning
            if (text.startsWith(query)) {
                score += 100
            }
            return score
        }
        
        return 0
    }

    ListModel {
        id: appListModel
    }

    Column {
        anchors.fill: parent
        anchors.margins: Theme.paddingLarge
        spacing: Theme.paddingLarge

        // Search bar
        Rectangle {
            width: parent.width
            height: 48
            radius: Theme.cornerRadiusSmall
            color: Theme.surface
            border.color: searchInput.activeFocus ? Theme.accent : Theme.border
            border.width: 2

            Row {
                anchors.fill: parent
                anchors.margins: Theme.padding
                spacing: Theme.padding

                Icon {
                    source: "󰍉"
                    size: Theme.fontSizeLarge
                    color: Theme.textSecondary
                    anchors.verticalCenter: parent.verticalCenter
                }

                TextInput {
                    id: searchInput
                    width: parent.width - 40
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSize
                    color: Theme.text
                    verticalAlignment: TextInput.AlignVCenter
                    selectByMouse: true
                    focus: true

                    Text {
                        visible: parent.text.length === 0
                        text: "Search applications..."
                        font: parent.font
                        color: Theme.textSecondary
                        verticalAlignment: Text.AlignVCenter
                    }

                    Keys.onEscapePressed: {
                        if (text.length > 0) {
                            text = ""
                        } else {
                            launcher.launchApp()
                        }
                    }
                    
                    Keys.onReturnPressed: {
                        // Launch first app in filtered list
                        if (appListModel.count > 0) {
                            var firstApp = appListModel.get(0)
                            launchApplication(firstApp.exec)
                        }
                    }
                }
            }
        }

        // App list - Grid or List view based on Config
        Loader {
            width: parent.width
            height: parent.height - 80
            
            sourceComponent: Config.launcher.grid ? gridViewComponent : listViewComponent
        }
    }

    // Grid View Component
    Component {
        id: gridViewComponent
        
        GridView {
            id: gridView
            clip: true
            cellWidth: width / 4
            cellHeight: 100

            model: appListModel

            delegate: Rectangle {
                required property string name
                required property string icon
                required property string exec
                
                width: GridView.view.cellWidth - Theme.padding
                height: GridView.view.cellHeight - Theme.padding
                radius: Theme.cornerRadiusSmall
                color: appMouseArea.containsMouse ? Theme.surface : "transparent"

                Column {
                    anchors.centerIn: parent
                    spacing: Theme.paddingSmall

                    Icon {
                        source: parent.parent.icon || "󰀻"
                        size: Theme.fontSizeMassive * 2
                        color: Theme.accent
                        anchors.horizontalCenter: parent.horizontalCenter
                    }

                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: parent.parent.name
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSizeSmall
                        color: Theme.text
                        elide: Text.ElideRight
                        width: GridView.view.cellWidth - Theme.paddingLarge * 2
                        horizontalAlignment: Text.AlignHCenter
                    }
                }

                MouseArea {
                    id: appMouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor

                    onClicked: {
                        launchApplication(parent.exec)
                    }
                }
            }
        }
    }

    // List View Component
    Component {
        id: listViewComponent
        
        ListView {
            id: listView
            clip: true
            spacing: Theme.paddingSmall

            model: appListModel

            delegate: Rectangle {
                required property string name
                required property string icon
                required property string exec
                required property string description
                
                width: listView.width
                height: 56
                radius: Theme.cornerRadiusSmall
                color: listMouseArea.containsMouse ? Theme.surface : "transparent"

                Row {
                    anchors.fill: parent
                    anchors.margins: Theme.padding
                    spacing: Theme.padding

                    Icon {
                        source: parent.parent.icon || "󰀻"
                        size: 32
                        color: Theme.accent
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    Column {
                        width: parent.width - 48
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 2

                        Text {
                            text: parent.parent.parent.name
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontSize
                            color: Theme.text
                            elide: Text.ElideRight
                            width: parent.width
                        }

                        Text {
                            text: parent.parent.parent.description || ""
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontSizeSmall
                            color: Theme.textSecondary
                            elide: Text.ElideRight
                            width: parent.width
                            visible: text.length > 0
                        }
                    }
                }

                MouseArea {
                    id: listMouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor

                    onClicked: {
                        launchApplication(parent.exec)
                    }
                }
            }
        }
    }

    function launchApplication(command) {
        if (!command || command.length === 0) return
        
        // Parse command to handle quotes and arguments properly
        var cmdParts = command.split(' ').filter(function(part) {
            return part.length > 0
        })
        
        if (cmdParts.length === 0) return
        
        console.log("Launching:", command)
        
        var proc = Qt.createQmlObject(
            'import Quickshell.Io; Process { command: ' + JSON.stringify(cmdParts) + '; running: true }',
            launcher,
            "appLauncher"
        )
        
        // Close launcher after launching app
        launcher.launchApp()
        
        // Clear search
        searchInput.text = ""
    }
}