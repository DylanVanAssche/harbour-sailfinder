import QtQuick 2.0
import QtPositioning 5.2
import org.nemomobile.dbus 2.0

Item {

    Component.onCompleted: location.start()

    PositionSource {
        id: location
        updateInterval: 60 * 1000
        preferredPositioningMethods: PositionSource.AllPositioningMethods
        onPositionChanged: {
            if(location.valid) {
                console.log("[INFO] Position is valid, sending location...")
                python.call("app.account.location", [location.position.coordinate.latitude, location.position.coordinate.longitude], function(result) {
                    if(result.status == 200) { // When we succesfully updated our location, stop to save power
                        console.log("[INFO] Location succesfully updated to: " + location.position.coordinate.latitude + " LAT " + location.position.coordinate.longitude + " LON")
                    }
                    else {
                        location.update()
                        console.log("[INFO] Location update failed, code: " + result.status)
                    }                    
                })
            }
            else {
                console.log("[INFO] Position is not valid, turn on location!")
                update() // Force an update when position invalid
            }
        }
    }
}
