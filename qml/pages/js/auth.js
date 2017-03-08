/*
Sailfinder Auth handles all the interaction in the authentication UI
*/

function auth(email, password) {
    python.call("app.account.auth", [email, password], function(result) {
        processResult(result)
    })
}

function processResult(result) {
    switch (result) {
        case 0: //Token expired
            tokenExpired = true
            toaster.previewBody = qsTr("Session expired, relogin please") + "..."
            toaster.publish()
            break;

        case 1: //Facebook username/password is wrong
            authenticating = false
            toaster.previewBody = qsTr("Facebook login failed, check your username/password") + "!"
            toaster.publish()
            break;

        case 2: //Tinder auth failed
            authenticating = false
            toaster.previewBody = qsTr("Tinder login failed, try again later") + "..."
            toaster.publish()
            break;

        case 3: //Connection timeout
            console.log("[ERROR] Authentication failed due a connection timeout!")
            authenticating = false
            toaster.previewBody = qsTr("Connection timeout, check your network connection") + "!"
            toaster.publish()
            break;

        case 4: //All good :)
            pageStack.replace(Qt.resolvedUrl("../MainPage.qml"))
            break;

        default: //Auth failed for unknown reason
            console.log("[ERROR] Authentication failed due an unkown reason!")
            authenticating = false
            toaster.previewBody = qsTr("Login failed, check the logfiles") + "..."
            toaster.publish()
            break;
    }
}
