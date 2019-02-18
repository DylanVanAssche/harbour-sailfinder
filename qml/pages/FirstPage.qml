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

import QtQuick 2.0
import Sailfish.Silica 1.0
import QtWebKit 3.0

Page {
    property string fbToken
    property bool clearData
    property string _mode: "facebook" // accountkit or facebook mode

    id: page

    onFbTokenChanged: {
        if(fbToken.length > 0) {
            loader.visible = true
            tinderLogin.visible = true
            api.login(fbToken)
        }
    }

    Connections {
        target: api
        onAuthenticatedChanged: {
            if(api.authenticated) {
                console.debug("Tinder token successfully retrieved")
                pageStack.replace(Qt.resolvedUrl("../pages/MainPage.qml"))
            }
        }
    }

    Connections {
        target: app
        onNetworkStatusChanged: {
            if(app.networkStatus) {
                console.debug("Network recovered, reloading webview")
                webview.reload()
            }
        }
    }

    SilicaWebView {
        id: webview

        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
            bottom: parent.bottom
        }
        clip: true
        experimental.preferences.javascriptEnabled: true
        experimental.preferences.navigatorQtObjectEnabled: true
        experimental.preferences.developerExtrasEnabled: true
        experimental.userStyleSheets: Qt.resolvedUrl("../css/authentication.css")
        experimental.userScripts: [Qt.resolvedUrl("../js/authentication.js")]
        experimental.userAgent: app.fbUserAgent
        experimental.preferredMinimumContentsWidth: 980 // Helps rendering desktop websites
        experimental.onMessageReceived: {
            var msg = JSON.parse(message.data);
            switch(msg.type) {
            case 0: // FB_TOKEN
                console.debug("Successfully retrieved Facebook access token: " + msg.data);
                fbToken = msg.data;
                errorLogin.enabled = false;
                opacity = 0.0;
                break;
            case 1: // PHONE_SUBMIT
                console.log("Phone submit OK, new URL:" + url)
                break;
            case 41: // ERROR
                console.error("Can't retrieve Facebook access token: " + msg.data);
                fbToken = "";
                errorLogin.enabled = true;
                opacity = 1.0;
                break;
            case 42: // DEBUG
                console.debug(msg.data);
                break;
            }
        }
        url: _mode === "accountkit"? app.accountkitAuthUrl: app.fbAuthUrl
        enabled: !loading // block input while loading
        Component.onCompleted: {
            if(clearData) {
                console.debug("Clearing cookies due logout")
                webview.experimental.deleteAllCookies();
                webview.reload()
            }
        }
        onLoadingChanged: {
            switch (loadRequest.status)
            {
            case WebView.LoadSucceededStatus:
                opacity = 1
                loader.visible = false
                reloadLogin.visible = false
                break
            case WebView.LoadFailedStatus:
                opacity = 0
                //% "Something went wrong, please try again later"
                sfos.createToaster(qsTrId("sailfinder-error"), "icon-s-high-importance", "sailfinder-login")
                loader.visible = true
                reloadLogin.visible = true
                break
            default:
                opacity = 0
                loader.visible = true
                reloadLogin.visible = false
                break
            }
        }

        FadeAnimation on opacity {}

        Behavior on opacity { FadeAnimation {} }

        PullDownMenu {
            MenuItem {
                text: _mode === "accountkit"?
                          //% "Use Facebook login"
                          qsTrId("sailfinder-login-facebook"):
                          //% "Use phone login"
                          qsTrId("sailfinder-login-phone")
                onClicked: {
                    _mode === "accountkit"? _mode = "facebook": _mode = "accountkit"
                    console.debug("Authentication mode: " + _mode)
                    pageStack.replace(Qt.resolvedUrl("../pages/LoginPhone.qml"))
                }
//                visible: false // Undo when phone login support is enabled
            }
        }

        ViewPlaceholder {
            id: errorLogin
            //% "Oops!"
            text: qsTrId("sailfinder-oops")
            //% "Something went wrong, please try again later"
            hintText: qsTrId("sailfinder-error")
        }
    }

    BusyIndicator {
        id: loader
        size: BusyIndicatorSize.Large
        anchors.centerIn: parent
        visible: false
        running: Qt.application.active && visible
    }

    Label {
        id: tinderLogin
        anchors { top: loader.bottom; topMargin: Theme.paddingMedium; horizontalCenter: parent.horizontalCenter }
        visible: false
        //% "Logging in"
        text: qsTrId("sailfinder-logging-in")
    }

    Button {
        id: reloadLogin
        anchors { top: loader.bottom; topMargin: Theme.paddingLarge; horizontalCenter: parent.horizontalCenter }
        visible: false
        //% "Reload"
        text: qsTrId("sailfinder-reload")
    }
}

