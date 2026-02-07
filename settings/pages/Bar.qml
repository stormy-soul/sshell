import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import "../../components/settings"
import "../../components/common"
import "../"

ContentPage {
    id: root
    property int gap: 15

    property var knownModules: ["Launcher", "Workspaces", "Mpris", "Clock", "Weather", "Battery", "Tray"]
    
    function getModulePosition(moduleName) {
        if (!Config.bar || !Config.bar.left) return "Disabled";
        for (var i = 0; i < Config.bar.left.length; i++) if (Config.bar.left[i].module === moduleName) return "Left";
        for (var i = 0; i < Config.bar.center.length; i++) if (Config.bar.center[i].module === moduleName) return "Center";
        for (var i = 0; i < Config.bar.right.length; i++) if (Config.bar.right[i].module === moduleName) return "Right";
        return "Disabled"; 
    }

    function setModulePosition(moduleName, newPos) {
        var removeFrom = function(arr) {
            var res = []
            for(var i=0; i<arr.length; i++) {
                if(arr[i].module !== moduleName) res.push(arr[i])
            }
            return res
        }
        
        var left = removeFrom(Config.bar.left)
        var center = removeFrom(Config.bar.center)
        var right = removeFrom(Config.bar.right)
        
        var entry = { "module": moduleName, "enabled": true }
        
        if (newPos === "Left") left.push(entry)
        else if (newPos === "Center") center.push(entry)
        else if (newPos === "Right") right.push(entry)
        
        Config.bar.left = left
        Config.bar.center = center
        Config.bar.right = right
    }

    ContentSection {
        title: "Bar Settings"
        icon: "monitor"

        ContentSubsection {
            title: "Position"
            ConfigSelectionArray {
                options: [
                    { displayName: "Top", value: "top" },
                    { displayName: "Bottom", value: "bottom" }
                ]
                currentValue: Config.bar.position
                onSelected: (val) => Config.bar.position = val
            }
        }
        
        ContentSubsection {
            title: "Style"
            ConfigSelectionArray {
                options: [
                    { displayName: "Floating", value: "floating" },
                    { displayName: "Modules", value: "modules" },
                    { displayName: "Islands", value: "islands" },
                    { displayName: "Full", value: "full" }
                ]
                currentValue: Config.bar.style
                onSelected: (val) => Config.bar.style = val
            }
        }
        
        ContentSubsection {
            title: "Height"
            Rectangle {
                Layout.preferredWidth: 100
                Layout.preferredHeight: 30
                color: Appearance.colors.surfaceVariant
                radius: Appearance.sizes.cornerRadius
                
                StyledTextInput {
                    anchors.fill: parent
                    anchors.margins: 4
                    text: Config.bar.height.toString()
                    horizontalAlignment: TextInput.AlignHCenter
                    verticalAlignment: TextInput.AlignVCenter
                    
                    onTextEdited: {
                        var val = parseInt(text)
                        if (!isNaN(val)) {
                            val = Math.max(10, Math.min(100, val))
                            Config.bar.height = val
                        }
                    }
                }
            }
        }
    }
    
    ContentSection {
        title: "Modules"
        icon: "widgets"
        space: root.gap
        
        Repeater {
            model: root.knownModules
            
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 5
                
                Text {
                    text: modelData
                    color: Appearance.colors.textSecondary
                    font.family: Appearance.font.family.main
                    font.pixelSize: Appearance.font.pixelSize.normal
                }
                
                ConfigSelectionArray {
                    options: [
                        { displayName: "Left", value: "Left" },
                        { displayName: "Center", value: "Center" },
                        { displayName: "Right", value: "Right" },
                        { displayName: "Off", value: "Disabled" }
                    ]
                    currentValue: getModulePosition(modelData)
                    onSelected: (val) => setModulePosition(modelData, val)
                }
            }
        }
    }
}

