import QtQuick 2.0
import QtPositioning 5.2

Item {

    Component.onCompleted: location.start()

    PositionSource {
        id: location
        updateInterval: 60 * 1000
        preferredPositioningMethods: PositionSource.AllPositioningMethods
        onPositionChanged: {
            if(valid) {
                console.log("[INFO] Position is valid, sending location...")
                python.call("app.account.location", [location.position.coordinate.latitude, location.position.coordinate.longitude], function(result) {
                    if(result.status == 200) { // When we succesfully updated our location, stop to save power
                        console.log("[INFO] Location succesfully updated")
                        location.stop()
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
