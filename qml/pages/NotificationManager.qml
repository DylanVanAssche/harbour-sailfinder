import QtQuick 2.0
import org.nemomobile.notifications 1.0


Item {
    id: notification
    property string summary
    property string body
    property string previewSummary
    property string previewBody
    function publish()
    {
        if(settings.showNotifications) {
            notify.summary = summary
            notify.body = body
            notify.previewSummary = previewSummary
            notify.previewBody = previewBody
            notify.publish()
        }
    }

    function close()
    {
        notify.close()
    }

    Notification {
        id: notify
        category: "/usr/share/harbour-sailfinder/qml/resources/notifications/x-habour.sailfinder.conf" // NEEDS CUSTOM FILE -> DEPENDS ON HARBOUR
        appName: "Sailfinder"
        appIcon: "/usr/share/harbour-sailfinder/qml/resources/images/launcher-logo.png"
        itemCount: 1
        timestamp: new Date("yyyy-MM-dd hh:mm:ss")
        replacesId: 0
    }
}

