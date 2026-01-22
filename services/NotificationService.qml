pragma Singleton
import QtQuick

QtObject {
    id: service
    
    property var notifications: []
    
    signal notificationAdded(var notification)
    signal notificationClosed(int id)

    function addNotification(title, body, icon) {
        let notification = {
            "id": Date.now(),
            "title": title,
            "body": body,
            "icon": icon || "",
            "timestamp": new Date()
        }

        let temp = notifications.slice()
        temp.push(notification)
        notifications = temp
        
        notificationAdded(notification)

        // Auto-dismiss after timeout
        let notifId = notification.id
        Qt.callLater(function() {
            closeNotification(notifId)
        }, Config.notifications.timeout || 5000)
    }

    function closeNotification(id) {
        notifications = notifications.filter(n => n.id !== id)
        notificationClosed(id)
    }
}