import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Io
import "../../components/settings"
import "../../components/common"
import "../"

ContentPage {
    id: root

    property var rawLines: []
    property var sections: []

    property var lineBuffer: []

    function loadKeybinds() {
        if (loadProcess.running) return
        root.lineBuffer = []
        loadProcess.running = true
    }

    function saveKeybinds() {
        if (saveProcess.running) return
        var content = root.rawLines.join("\n")
        // Use bash to handle redirection easily
        saveProcess.command = ["bash", "-c", "echo -n '" + content.replace(/'/g, "'\\''") + "' > " + Directories.hyprHome + "/keybinds.conf"]
        saveProcess.running = true
    }
    
    Process {
        id: loadProcess
        command: ["cat", Directories.hyprHome + "/keybinds.conf"]
        stdout: SplitParser {
            onRead: data => {
                root.lineBuffer.push(data)
            }
        }
        onExited: (code) => {
            if (code === 0) {
                root.rawLines = root.lineBuffer
                root.parseKeybinds(root.rawLines)
            } else {
                 console.error("Keybinds: Failed to load keybinds")
            }
        }
    }
    
    Process {
        id: saveProcess
    }

    function parseKeybinds(lines) {
        var newSections = []
        var currentSection = null
        var currentGroup = null

        for (var i = 0; i < lines.length; i++) {
            var line = lines[i].trim()
            var rawLine = lines[i]

            if (line === "") continue

            // Section Handling using ##!
            if (line.startsWith("##!")) {
                if (currentSection) newSections.push(currentSection)
                currentSection = {
                    title: line.substring(3).trim(),
                    items: []
                }
                currentGroup = null
                continue
            }

            if (line.includes("# [hidden]")) continue
            if (line.endsWith("# [hidden]")) continue

            if (line.startsWith("#") && !line.startsWith("##!")) {
                if (!line.includes("bind") && !line.includes("exec")) {
                    currentGroup = line.substring(1).trim()
                    if (currentSection) {
                       currentSection.items.push({
                          type: "group",
                          title: currentGroup
                       })
                    }
                    continue
                }
            }


            var isEnabled = !line.startsWith("#")
            var content = isEnabled ? line : line.substring(1).trim()
            
            if (content.startsWith("bind")) {
                var parts = content.split("#")
                var description = ""
                var bindPart = content
                
                if (parts.length > 1) {
                    description = parts[parts.length - 1].trim()
                    bindPart = parts.slice(0, parts.length - 1).join("#").trim()
                }
                var bindComponents = bindPart.split(",")
                if (bindComponents.length >= 2) {
                    var mods = bindComponents[0].replace("bind", "").replace("=", "").trim()
                    var key = bindComponents[1].trim()
                    
                    var title = description !== "" ? description : "Keybind"
                    var subtitle = bindPart.replace(/bind[a-z]*\s*=\s*/, "") // Remove 'bind = '
                    
                    if (currentSection) {
                        currentSection.items.push({
                            type: "bind",
                            title: title,
                            subtitle: subtitle,
                            keyCombo: mods + "+" + key,
                            enabled: isEnabled,
                            lineIndex: i
                        })
                    }
                }
            }
        }
        if (currentSection) newSections.push(currentSection)
        root.sections = newSections
    }

    function toggleBind(index, enabled) {
        var line = root.rawLines[index]
        if (enabled) {
            if (line.trim().startsWith("#")) {
                root.rawLines[index] = line.replace("#", "")
            }
        } else {
            if (!line.trim().startsWith("#")) {
                root.rawLines[index] = "#" + line
            }
        }
        saveKeybinds()
        loadKeybinds() 
    }

    Component.onCompleted: loadKeybinds()

    Repeater {
        model: root.sections
        delegate: ContentSection {
            Rectangle {
                Layout.fillWidth: true
                height: 1
                color: Appearance.colors.border
                opacity: 0.5
            }
            title: modelData.title
            
            Repeater {
                model: modelData.items
                delegate: Loader {
                    Layout.fillWidth: true
                    Layout.bottomMargin: 10
                    sourceComponent: modelData.type === "group" ? groupHeader : bindItem
                    
                    property var itemData: modelData

                    Component {
                        id: groupHeader
                        Text {
                            text: itemData.title
                            color: Appearance.colors.accent
                            font.bold: true
                            font.pixelSize: Appearance.font.pixelSize.small
                            font.family: Appearance.font.family.main
                            topPadding: 10
                        }
                    }

                    Component {
                        id: bindItem
                        RowLayout {
                            Layout.fillWidth: true
                            Layout.bottomMargin: 10
                            spacing: 10
                            
                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 2
                                Text {
                                    text: itemData.title
                                    color: Appearance.colors.text
                                    font.pixelSize: Appearance.font.pixelSize.normal
                                    font.family: Appearance.font.family.main
                                }
                                Text {
                                    text: itemData.subtitle
                                    color: Appearance.colors.textSecondary
                                    font.pixelSize: Appearance.font.pixelSize.small
                                    font.family: Appearance.font.family.main
                                    elide: Text.ElideRight
                                    Layout.fillWidth: true
                                }
                            }

                            Rectangle {
                                Layout.alignment: Qt.AlignVCenter
                                color: Appearance.colors.overlayBackground
                                radius: Appearance.sizes.cornerRadiusSmall
                                width: keyText.implicitWidth + 16
                                height: 24
                                
                                Text {
                                    id: keyText
                                    anchors.centerIn: parent
                                    text: itemData.keyCombo
                                    color: Appearance.colors.text
                                    font.pixelSize: Appearance.font.pixelSize.small
                                    font.family: Appearance.font.family.main
                                }
                            }

                            StyledSwitch {
                                checked: itemData.enabled
                                onClicked: {
                                    root.toggleBind(itemData.lineIndex, !itemData.enabled)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
