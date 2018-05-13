/*
*   This file is part of Sailfinder.
*
*   Sailfinder is free software: you can redistribute it and/or modify
*   it under the terms of the GNU General Public License as published by
*   the Free Software Foundation, either version 3 of the License, or
*   (at your option) any later version.
*
*   Sailfinder is distributed in the hope that it will be useful,
*   but WITHOUT ANY WARRANTY; without even the implied warranty of
*   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
*   GNU General Public License for more details.
*
*   You should have received a copy of the GNU General Public License
*   along with Sailfinder.  If not, see <http://www.gnu.org/licenses/>.
*/

var msgCode = {"FB_TOKEN": 0, "SUBMIT_PHONE": 1, "SUBMIT_ACCOUNT": 2, "TINDER_TOKEN": 3, "ERROR": 41, "DEBUG": 42};

// Create our JSON payload and send it to QML
function send(type, data) {
    var payload = new Object;
    payload.type = type;
    payload.data = data;
    navigator.qt.postMessage(JSON.stringify(payload))
}

// Receiver dispatcher
navigator.qt.onmessage = function(msg) {
    var payload = JSON.parse(msg)
    if(msg.type === "SUBMIT_PHONE") {
        submitPhoneNumber(payload.land_code, payload.number)
    }
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

// Create our JSON payload and send it to QML
function send(type, data) {
    var payload = new Object;
    payload.type = type;
    payload.data = data;
    navigator.qt.postMessage(JSON.stringify(payload))
}

// Submit phone number form
function submitPhoneNumber(landCode, number) {
    var inputFields = document.forms[0].getElementsByTagName("input");
    inputFields[1].value = landCode;
    inputFields[2].value = number;
    document.forms[0].submit();
    send(msgCode["SUBMIT_PHONE"], true);
}
