import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Io
import "../../../settings"
import "../../common"
import "../../../services"

DetailWindow {
    id: root
    title: "Wi-Fi"
    
    headerRightItem: MaterialIcon {
        icon: "sync"
        width: 20
        height: 20
        color: Appearance.colors.text
        
        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: scan()
        }
    }
    
    property bool scanning: true
    
    Component.onCompleted: scan()
    
    function scan() {
        root.scanning = true
        scanProc.running = true
    }
    
    Process {
        id: scanProc
        command: ["nmcli", "device", "wifi", "rescan"]
        onExited: {
           listProc.running = true
        }
    }
    
    Process {
        id: listProc
        command: ["bash", "-c", "nmcli -t -f SSID,SIGNAL,SECURITY,ACTIVE device wifi list | sed 's/\\\\:/\\x00/g'"]
        
        property string outputBuffer: ""
        
        stdout: SplitParser {
            onRead: data => {
                listProc.outputBuffer += data + "\n"
            }
        }
        
        onExited: (exitCode) => {
            var lines = listProc.outputBuffer.split("\n")
            var uniqueSsids = {}
            var list = []
            
            for (var i = 0; i < lines.length; i++) {
                var line = lines[i].trim()
                if (!line) continue
                
                var parts = line.split(":")
                if (parts.length < 4) continue

                var active = parts[parts.length - 1] === "yes"
                var security = parts[parts.length - 2]
                var signal = parseInt(parts[parts.length - 3])
                // SSID is everything before the last 3 fields, restore escaped colons
                var ssid = parts.slice(0, parts.length - 3).join(":").replace(/\x00/g, ":")
                
                if (isNaN(signal)) signal = 0
                
                if (ssid && !uniqueSsids[ssid]) {
                    uniqueSsids[ssid] = true
                    list.push({ ssid: ssid, signal: signal, security: security, active: active })
                }
            }
            
            list.sort((a, b) => {
                if (a.active) return -1
                if (b.active) return 1
                return b.signal - a.signal
            })
            
            networksModel.clear()
            for (var j = 0; j < list.length; j++) {
                networksModel.append(list[j])
            }
            
            listProc.outputBuffer = ""
            root.scanning = false
        }
    }

    Process {
        id: connectProc
        property string ssid
        property string password
        
        onExited: (code) => {
             if (code === 0) {
                 scan() 
             } 
        }
    }
    
    Process {
        id: disconnectProc
        property string ssid
        command: ["nmcli", "connection", "down", "id", ssid]
        onExited: scan()
    }
    
    function connect(ssid, password) {
        if (password) {
            connectProc.command = ["nmcli", "device", "wifi", "connect", ssid, "password", password]
        } else {
            connectProc.command = ["nmcli", "device", "wifi", "connect", ssid]
        }
        connectProc.ssid = ssid
        connectProc.running = true
    }
    
    ListModel { id: networksModel }
    
    content: ColumnLayout {
        Layout.fillWidth: true
        Layout.fillHeight: true
        
        ListView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            model: networksModel
            spacing: 5
            
            delegate: Rectangle {
                width: ListView.view.width
                height: 50
                radius: Appearance.sizes.cornerRadius
                color: mouse.containsMouse ? Appearance.colors.surfaceHover : "transparent"
                Behavior on color { ColorAnimation { duration: Appearance.animation.duration } }

                function getSignalIcon(strength) {
                    if (strength > 80) return "signal_wifi_4_bar"
                    if (strength > 60) return "signal_wifi_3_bar"
                    if (strength > 40) return "signal_wifi_2_bar"
                    if (strength > 20) return "signal_wifi_1_bar"
                    return "signal_wifi_0_bar"
                }
                
                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 5
                    spacing: 10
                    
                    MaterialIcon {
                        icon: getSignalIcon(model.signal)
                        width: 20
                        height: 20
                        color: model.active ? Appearance.colors.accent : Appearance.colors.text
                    }
                    
                    Text {
                        text: model.ssid
                        color: model.active ? Appearance.colors.accent : Appearance.colors.text
                        font.family: Appearance.font.family.main
                        Layout.fillWidth: true
                        elide: Text.ElideRight
                    }
                    
                    MaterialIcon {
                        visible: model.security !== ""
                        icon: "lock" 
                        width: 14
                        height: 14
                        color: Appearance.colors.textSecondary
                    }

                    RippleButton {
                        buttonText: model.active ? "Disconnect" : "Connect"
                        Layout.preferredHeight: 30
                        Layout.preferredWidth: 100
                        buttonRadius: Appearance.sizes.cornerRadius
                        
                        colBackground: "transparent"
                        colBackgroundHover: Appearance.colors.accent
                        colRipple: Appearance.colors.colOnPrimary

                        onClicked: {
                            if (model.active) {
                                disconnectProc.ssid = model.ssid
                                disconnectProc.running = true
                            } else {
                                if (model.security !== "") {
                                    passwordDialog.ssid = model.ssid
                                    passwordDialog.open()
                                } else {
                                    root.connect(model.ssid, null)
                                }
                            }
                        }
                    }
                }
                
                MouseArea {
                    id: mouse
                    anchors.fill: parent
                    z: -1
                    hoverEnabled: true
                    onClicked: {
                        if (!model.active) {
                            if (model.security !== "") {
                                passwordDialog.ssid = model.ssid
                                passwordDialog.open()
                            } else {
                                root.connect(model.ssid, null)
                            }
                        }
                    }
                }
            }
        }

        // Wired at bottom
        ColumnLayout {
            Layout.fillWidth: true
            visible: Network.ethernetConnected
            spacing: 5
            
            Item { Layout.fillWidth: true; Layout.preferredHeight: 10 } // Spacer
            
            Text {
                text: "Wired"
                color: Appearance.colors.textSecondary
                font.family: Appearance.font.family.main
                font.pixelSize: Appearance.font.pixelSize.small
                font.bold: true
            }
            
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 40
                radius: Appearance.sizes.cornerRadius
                color: Appearance.colors.surfaceVariant
                
                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 10
                    spacing: 10
                    
                    MaterialIcon {
                        icon: "settings_ethernet"
                        width: 20
                        height: 20
                        color: Appearance.colors.accent
                    }
                    
                    Text {
                        text: Network.ethernetDevice || "Ethernet"
                        color: Appearance.colors.text
                        font.family: Appearance.font.family.main
                        Layout.fillWidth: true
                    }
                    
                    Text {
                        text: "Connected"
                        color: Appearance.colors.textSecondary
                        font.family: Appearance.font.family.main
                        font.pixelSize: Appearance.font.pixelSize.small
                    }
                }
            }
        }
    
        // Simple password dialog
        Dialog {
            id: passwordDialog
            title: "Enter Password"
            property string ssid: ""
            
            anchors.centerIn: parent
            width: parent.width * 0.9
            
            modal: true
            closePolicy: Popup.CloseOnEscape
            
            background: Rectangle {
                color: Appearance.colors.surface
                border.color: Appearance.colors.border
                radius: Appearance.sizes.cornerRadius
            }
            
            contentItem: ColumnLayout {
                spacing: 10
                
                Text {
                    text: "Password for " + passwordDialog.ssid
                    color: Appearance.colors.text
                    font.family: Appearance.font.family.main
                } 
                
                TextField {
                    id: passField
                    Layout.fillWidth: true
                    echoMode: TextInput.Password
                    color: Appearance.colors.text
                    background: Rectangle { 
                        color: Appearance.colors.surfaceVariant
                        radius: Appearance.sizes.cornerRadius
                    }
                    
                    onAccepted: {
                        root.connect(passwordDialog.ssid, text)
                        passwordDialog.close()
                        text = ""
                    }
                }
                
                RowLayout {
                    Layout.alignment: Qt.AlignRight
                    Button {
                        text: "Cancel"
                        onClicked: passwordDialog.close()
                    }
                    Button {
                        text: "Connect"
                        onClicked: {
                            root.connect(passwordDialog.ssid, passField.text)
                            passwordDialog.close()
                            passField.text = ""
                        }
                    }
                }
            }
        }
    }
}