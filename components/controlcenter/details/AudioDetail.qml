import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Io
import "../../../settings"
import "../../common"

DetailWindow {
    id: root
    title: "Audio"
    
    Component.onCompleted: {
        sinksProc.running = true
        sourcesProc.running = true
    }
    
    Process {
        id: sinksProc
        command: ["pactl", "list", "sinks", "short"]
        stdout: SplitParser {
            onRead: data => {
                var lines = data.split("\n")
                for (var i=0; i<lines.length; i++) {
                    var line = lines[i].trim()
                    if (!line) continue
                    var parts = line.split("\t")
                    if (parts.length >= 5) {
                        var name = parts[1]
                        var state = parts[4] // RUNNING, SUSPENDED, IDLE
                        var active = (state === "RUNNING")
                        var friendly = name.replace(/alsa_output\.[^.]+\.[^.]+\.HiFi__/, "").replace(/__sink$/, "").replace(/__/g, " ").replace(/_/g, " ")
                        outputModel.append({ name: friendly, fullName: name, active: active })
                    }
                }
            }
        }
    }
    
    Process {
        id: sourcesProc
        command: ["pactl", "list", "sources", "short"]
        stdout: SplitParser {
            onRead: data => {
                var lines = data.split("\n")
                for (var i=0; i<lines.length; i++) {
                    var line = lines[i].trim()
                    if (!line) continue
                    if (line.indexOf(".monitor") !== -1) continue
                    var parts = line.split("\t")
                    if (parts.length >= 5) {
                        var name = parts[1]
                        var state = parts[4]
                        var active = (state === "RUNNING")
                        var friendly = name.replace(/alsa_input\.[^.]+\.[^.]+\.HiFi__/, "").replace(/__source$/, "").replace(/__/g, " ").replace(/_/g, " ")
                        inputModel.append({ name: friendly, fullName: name, active: active })
                    }
                }
            }
        }
    }
    
    ListModel { id: outputModel }
    ListModel { id: inputModel }
    
    content: ColumnLayout {
        Layout.fillWidth: true
        Layout.fillHeight: true
        spacing: Appearance.sizes.paddingLarge
        
        Text {
            text: "Output Devices"
            color: Appearance.colors.textSecondary
            font.family: Appearance.font.family.main
            font.bold: true
        }
        
        ListView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            model: outputModel
            delegate: AudioDeviceDelegate { isInput: false }
            spacing: Appearance.sizes.paddingSmall
        }
        
        Text {
            text: "Input Devices"
            color: Appearance.colors.textSecondary
            font.family: Appearance.font.family.main
            font.bold: true
        }
        
        ListView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            model: inputModel
            delegate: AudioDeviceDelegate { isInput: true }
            spacing: Appearance.sizes.paddingSmall
        }
    }
    
    component AudioDeviceDelegate: Rectangle {
        width: ListView.view.width
        height: 40
        radius: Appearance.sizes.cornerRadius
        color: model.active ? Appearance.colors.surfaceVariant : Appearance.colors.overlayBackground
        
        property bool isInput: false
        
        function getIcon() {
            var name = model.name.toLowerCase()
            if (isInput) {
                return "mic"
            }
            if (name.indexOf("hdmi") !== -1) return "cable"
            if (name.indexOf("headphone") !== -1) return "headphones"
            if (name.indexOf("speaker") !== -1) return "speaker"
            if (name.indexOf("bluetooth") !== -1) return "bluetooth"
            return "volume_up"
        }
        
        RowLayout {
            anchors.fill: parent
            anchors.margins: 10
            spacing: 10
            
            MaterialIcon {
                icon: getIcon()
                width: 20
                height: 20
                color: Appearance.colors.accent
            }
            
            Text {
                text: model.name
                color: Appearance.colors.text
                font.family: Appearance.font.family.main
                Layout.fillWidth: true
                elide: Text.ElideRight
            }
        }
    }
}
