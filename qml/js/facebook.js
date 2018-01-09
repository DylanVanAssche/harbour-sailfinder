var msgCode = {"FB_TOKEN": 0, "ERROR": 1, "DEBUG": 42};

// Create our JSON payload and send it to QML
function send(type, data) {
    var payload = new Object;
    payload.type = type;
    payload.data = data;
    navigator.qt.postMessage(JSON.stringify(payload))
}

// Filters the access token from the Facebook OAuth hidden page
function filterAccessToken(data) {
    var accessTokenFilterRegex = /(?=access_token=)(.+?)(?=&)/;

    // Run the RegExp on the document data
    var accessToken = accessTokenFilterRegex.exec(data)[0]

    // Check if the RegExp found our access_token and split it
    if(accessToken.indexOf("access_token=") !== -1) {
        accessToken = accessToken.split("=")[1];
        send(msgCode["FB_TOKEN"], accessToken);
    }
    // If not, send out an error message
    else {
        send(msgCode["ERROR"], accessToken);
    }

    send(msgCode["DEBUG"], accessToken);
}

filterAccessToken(document.documentElement.innerHTML)
