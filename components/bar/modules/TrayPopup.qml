import QtQuick
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects
import Quickshell
import Quickshell.Services.SystemTray
import Quickshell.Wayland
import "../../../settings"
import "../../../services"
import "../common"

PanelWindow {
    id: root
    
    property string position: Config.bar.position || "bottom"
    property real sourceCenter: 0
    
    anchors {
        bottom: position === "bottom"
        top: position === "top"
        left: true 
    }
    
    margins {
        bottom: position === "bottom" ? (Appearance.sizes.barHeight + Appearance.sizes.barMargin + 10) : 0
        top: position === "top" ? Appearance.sizes.barMargin: 0
        left: Math.max(Appearance.sizes.paddingLarge, (sourceCenter - (width / 2)) + 10)
    }
    
    implicitWidth: trayContent.width + (Appearance.sizes.padding * 2)
    implicitHeight: trayContent.height + (Appearance.sizes.padding * 2)
    
    property bool shown: false
    visible: shown
    opacity: ShellState.masterVisible ? 1 : 0
    mask: Region {
        item: ShellState.masterVisible ? background : null
    } 
    
    color: "transparent"

    WlrLayershell.namespace: "sshell:popup"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
    
    Rectangle {
        id: background
        anchors.fill: parent
        color: Appearance.colors.overlayBackground
        radius: Appearance.sizes.cornerRadiusLarge
        border.width: 1
        border.color: Qt.rgba(Appearance.colors.border.r, Appearance.colors.border.g, Appearance.colors.border.b, 0.2)
        
        GridLayout {
            id: trayContent
            anchors.centerIn: parent
            
            property int itemCount: SystemTray.items.values.length
            columns: itemCount < 3 ? itemCount : 3
            
            columnSpacing: Appearance.sizes.padding
            rowSpacing: Appearance.sizes.padding
            
            Repeater {
                model: SystemTray.items.values
                
                Rectangle {
                    id: delegateRoot
                    required property var modelData
                    
                    width: 30
                    height: 30
                    color: hoverArea.containsMouse ? Appearance.colors.surfaceHover : "transparent"
                    radius: Appearance.sizes.cornerRadiusSmall
                    
                    Image {
                        id: trayIcon
                        anchors.fill: parent
                        anchors.margins: 4
                        
                        fillMode: Image.PreserveAspectFit
                        smooth: true
                        mipmap: true
                        asynchronous: true
                        
                        property var candidates: []
                        property int currentCandidateIndex: 0
                        
                        Component.onCompleted: {
                            generateCandidates()
                            loadCurrentCandidate()
                        }
                        
                        onStatusChanged: {
                            if (status === Image.Error) {
                                if (currentCandidateIndex < candidates.length - 1) {
                                    currentCandidateIndex++
                                    loadCurrentCandidate()
                                }
                            }
                        }
                        
                        function loadCurrentCandidate() {
                            if (candidates.length > 0 && currentCandidateIndex < candidates.length) {
                                source = candidates[currentCandidateIndex]
                            } else {
                                source = "image://icon/system-run" 
                            }
                        }
                        
                        function generateCandidates() {
                            var list = []
                            var iconStr = parent.modelData.icon || ""
                            
                            if (!iconStr) {
                                list.push("image://icon/system-run")
                                candidates = list
                                return
                            }
                            
                            if (iconStr.indexOf("?") !== -1) {
                                var parts = iconStr.split("?")
                                var name = parts[0]
                                var query = parts[1]
                                
                                if (name.startsWith("image://icon/")) name = name.substring(13)
                                if (name.startsWith("file://")) name = name.substring(7)
                                
                                var pathMatch = query.match(/path=([^&]+)/)
                                
                                if (pathMatch) {
                                    var basePath = "file://" + pathMatch[1] + "/" + name
                                    list.push(basePath + ".png")
                                    list.push(basePath + ".tga")
                                    list.push(basePath + ".svg")
                                    list.push(basePath + ".ico")
                                    list.push(basePath) 
                                }
                                iconStr = name 
                            }
                            
                            if (iconStr.startsWith("/")) {
                                list.push("file://" + iconStr)
                            }
                            else if (iconStr.startsWith("file://")) {
                                list.push(iconStr)
                            }
                            else if (iconStr.startsWith("image://")) {
                                list.push(iconStr)
                            }
                            else {
                                list.push("image://icon/" + iconStr)
                            }
                            
                            if (iconStr.indexOf("/") === -1 && !list.includes("image://icon/" + iconStr)) {
                                list.push("image://icon/" + iconStr)
                            }
                            
                            candidates = list
                        }
                    }
                    
                    MouseArea {
                        id: hoverArea
                        anchors.fill: parent
                        hoverEnabled: true
                        acceptedButtons: Qt.LeftButton | Qt.RightButton
                        
                        onClicked: (mouse) => {
                            if (mouse.button === Qt.LeftButton) {
                                modelData.activate()
                                root.shown = false
                            } else if (mouse.button === Qt.RightButton) {
                                if (modelData.menu) {
                                    startMenuAnchor.menu = modelData.menu
                                    startMenuAnchor.open()
                                }
                            }
                        }
                    }
                    
                    QsMenuAnchor {
                        id: startMenuAnchor
                        anchor {
                            item: delegateRoot
                            gravity: Edges.Bottom | Edges.Right
                            edges: Edges.Bottom | Edges.Right
                        }
                    }
                }
            }
        }
    }
}
