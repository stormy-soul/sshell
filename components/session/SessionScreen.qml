import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import "../common"
import "../../settings"
import "../../services"

PanelWindow {
    id: root
    
    property bool shown: false
    visible: shown
    
    color: "transparent"
    WlrLayershell.namespace: "sshell:session"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
    exclusionMode: ExclusionMode.Ignore
    
    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }
    
    Rectangle {
        id: dimBackground
        anchors.fill: parent
        color: Appearance.colors.overlayBackground
        opacity: root.shown ? 1 : 0
        Behavior on opacity { NumberAnimation { duration: 200 } }
        
        MouseArea {
            anchors.fill: parent
            onClicked: root.close()
        }
    }
    
    FocusScope {
        id: focusScope
        anchors.centerIn: parent
        width: contentColumn.width
        height: contentColumn.height
        focus: true
        
        ColumnLayout {
            id: contentColumn
            spacing: 30
            
            ColumnLayout {
                Layout.alignment: Qt.AlignHCenter
                spacing: 5
                
                Text {
                    text: "Session"
                    font.family: Appearance.font.family.title
                    font.pixelSize: Appearance.font.pixelSize.massive
                    font.weight: Font.Bold
                    color: Appearance.colors.text
                    Layout.alignment: Qt.AlignHCenter
                }
                
                Text {
                    text: "Uptime: " + SystemInfo.uptime
                    font.family: Appearance.font.family.main
                    font.pixelSize: Appearance.font.pixelSize.normal
                    color: Appearance.colors.textSecondary
                    Layout.alignment: Qt.AlignHCenter
                    visible: SystemInfo.uptime !== "--:--"
                }
            }
            
            RowLayout {
                spacing: 20
                Layout.alignment: Qt.AlignHCenter
                
                SessionButton {
                    id: btnShutdown
                    ic: "power_settings_new"
                    label: "Shutdown"
                    focus: true
                    KeyNavigation.right: btnReboot
                    KeyNavigation.left: btnLogout
                    onClicked: shutdownProc.running = true
                }
                
                SessionButton {
                    id: btnReboot
                    ic: "restart_alt"
                    label: "Reboot"
                    KeyNavigation.left: btnShutdown
                    KeyNavigation.right: btnSuspend
                    onClicked: rebootProc.running = true
                }
                
                SessionButton {
                    id: btnSuspend
                    ic: "bedtime"
                    label: "Suspend"
                    KeyNavigation.left: btnReboot
                    KeyNavigation.right: btnLogout
                    onClicked: suspendProc.running = true
                }
                
                SessionButton {
                    id: btnLogout
                    ic: "logout"
                    label: "Log Out"
                    KeyNavigation.left: btnSuspend
                    KeyNavigation.right: btnShutdown
                    onClicked: logoutProc.running = true
                }
                
                Component.onCompleted: btnShutdown.forceActiveFocus()
            }
            Text {
                text: "Use arrow keys to navigate, Enter to select, Esc to cancel"
                font.family: Appearance.font.family.main
                font.pixelSize: Appearance.font.pixelSize.small
                color: Appearance.colors.textSecondary
                Layout.alignment: Qt.AlignHCenter
                opacity: 0.7
            }
        }

        Keys.onEscapePressed: root.close()
    }
    
    function toggle() {
        root.shown = !root.shown
        if (root.shown) {
            btnShutdown.forceActiveFocus()
        }
    }
    
    function close() {
        root.shown = false
    }
    
    Process {
        id: shutdownProc
        command: ["systemctl", "poweroff"]
        onExited: root.close()
    }
    
    Process {
        id: rebootProc
        command: ["systemctl", "reboot"]
        onExited: root.close()
    }
    
    Process {
        id: suspendProc
        command: ["systemctl", "suspend"]
        onExited: root.close()
    }
    
    Process {
        id: logoutProc
        command: ["loginctl", "terminate-user", "$USER"] 
        onExited: root.close()
    }
}
