pragma Singleton
import QtQuick

QtObject {
    id: root
    
    property var notifications: []

    function push(title, body) {
        console.log("NotificationService received:", title)
        
        const newNotif = {
            id: Date.now().toString(),
            title: title,
            body: body
        }
        
        let list = root.notifications
        list.push(newNotif)
        root.notifications = list
        
        dismissTimer.createObject(root, { notifId: newNotif.id })
    }
    
    function close(id) {
        root.notifications = root.notifications.filter(n => n.id !== id)
    }

    property Component dismissTimer: Timer {
        property string notifId
        interval: 5000
        running: true
        onTriggered: {
            root.close(notifId)
            destroy()
        }
    }
}