pragma Singleton
import QtQuick
import Quickshell.Services.Notifications
import "../settings"

QtObject {
    id: root
    
    property var notifications: []

    property var activeTimers: ({})

    function push(title, body, image, id, timeout) {
        console.log("NotificationService received:", title)
        
        const newNotif = {
            id: id ? id.toString() : Date.now().toString(),
            title: title,
            body: body,
            body: body,
            image: image || "",
            shownInPopup: !dnd
        }
        
        var list = root.notifications.concat([newNotif])
        root.notifications = list
        
        if (newNotif.shownInPopup) {
            var timer = dismissTimer.createObject(root, { 
                notifId: newNotif.id,
                interval: (timeout && timeout > 0) ? timeout : (Config.notifications.timeout || 5000)
            })
            root.activeTimers[newNotif.id] = timer
        }
    }
    
    property NotificationServer server: NotificationServer {
        id: server
        bodySupported: true
        imageSupported: true
        
        onNotification: (n) => {
            let img = n.image || n.appIcon || ""
            
            root.push(n.summary, n.body, img, n.id, n.expireTimeout)
        }
    }
    
    function expire(id) {
        if (root.activeTimers[id]) {
            root.activeTimers[id].destroy()
            delete root.activeTimers[id]
        }
        
        const index = root.notifications.findIndex(n => n.id === id)
        if (index !== -1) {
            let notif = root.notifications[index]
            let newNotif = Object.assign({}, notif, { shownInPopup: false })
            let list = [...root.notifications]
            list[index] = newNotif
            root.notifications = list
        }
    }

    function close(id) {
        if (root.activeTimers[id]) {
            root.activeTimers[id].destroy()
            delete root.activeTimers[id]
        }
        
        root.notifications = root.notifications.filter(n => n.id !== id)
    }

    function pauseTimer(id) {
        if (root.activeTimers[id]) {
            root.activeTimers[id].running = false
            console.log("Paused timer for:", id)
        }
    }

    function resumeTimer(id) {
        if (root.activeTimers[id]) {
            root.activeTimers[id].restart()
            console.log("Resumed timer for:", id)
        }
    }

    property Component dismissTimer: Timer {
        property string notifId
        interval: Config.notifications.timeout || 5000
        running: true
        repeat: false
        onTriggered: {
            root.expire(notifId)
        }
    }
    property bool dnd: false
    function toggleDnd() { dnd = !dnd }
    
    function sendTestNotification() {
        push("Test Notification", "This is a test notification body with some longer text to test wrapping behavior.", "notifications_active")
    }
}