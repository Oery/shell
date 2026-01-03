import QtQuick
import Quickshell
import Quickshell.Services.Notifications

NotificationServer {
    id: notificationServer
    
    bodySupported: true
    actionsSupported: true
    actionIconsSupported: true
    imageSupported: true
    bodyMarkupSupported: true
    bodyHyperlinksSupported: true
    bodyImagesSupported: true
    inlineReplySupported: true
    persistenceSupported: false
    keepOnReload: true
    
    onNotification: notification => {
        console.log("Received notification: " + notification.summary);
        
        notification.tracked = true
        
        var popupComponent = Qt.createComponent("NotificationPopup.qml");
        if (popupComponent.status === Component.Ready) {
            var popup = popupComponent.createObject(notificationServer, { 
                notification: notification
            });
            
            if (popup) {
                console.log("Created notification popup successfully");
                
                notification.closed.connect(reason => {
                    console.log("Notification closed: " + reason);
                    if (popup) {
                        popup.destroy();
                    }
                });
            } else {
                console.log("Failed to create popup object");
            }
        } else {
            console.log("Failed to create NotificationPopup: " + popupComponent.errorString());
        }
    }
}