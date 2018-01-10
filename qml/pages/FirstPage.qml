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
    property string tinderToken
    onFbTokenChanged: fbToken.length > 0? tinderLogin.visible = true: tinderLogin.visible = false
    onTinderTokenChanged: tinderToken.length > 0? pageStack.push(Qt.resolvedUrl("../pages/MainPage.qml")): undefined

    SilicaFlickable {
        anchors.fill: parent

        PageHeader {
            id: header
            anchors {
                top: parent.top
                left: parent.left
                right: parent.right
            }
            //: Header on the login screen
            //% "Login"
            title: qsTrId("sailfinder-login-header")
        }

        SilicaWebView {
            // Rounding floating numbers in JS: https://stackoverflow.com/questions/9453421/how-to-round-float-numbers-in-javascript
            // Default 1.5x zoom
            property real _devicePixelRatio: Math.round(1.5*Theme.pixelRatio * 10) / 10.0

            anchors {
                top: header.bottom
                bottom: parent.bottom
                left: parent.left
                right: parent.right
            }
            experimental.preferences.javascriptEnabled: true
            experimental.preferences.navigatorQtObjectEnabled: true
            experimental.preferences.developerExtrasEnabled: true
            experimental.userScripts: [Qt.resolvedUrl("../js/facebook.js")]
            experimental.customLayoutWidth: parent.width / _devicePixelRatio
            experimental.overview: true
            experimental.userAgent: app.userAgent
            experimental.onMessageReceived: {
                var msg = JSON.parse(message.data);
                switch(msg.type) {
                case 0: // FB_TOKEN
                    console.debug("Successfully retrieved Facebook access token: " + msg.data);
                    fbToken = msg.data;
                    errorFacebookLogin.enabled = false;
                    opacity = 0.0;
                    break;
                case 1: // ERROR
                    console.error("Can't retrieve Facebook access token: " + msg.data);
                    fbToken = "";
                    errorFacebookLogin.enabled = true;
                    opacity = 1.0;
                    break;
                case 42: // DEBUG
                    console.debug(msg.data);
                    break;
                }
            }
            url: app.fbAuthUrl

            Behavior on opacity { FadeAnimation {} }

            ViewPlaceholder {
                id: errorFacebookLogin
                //% "Oops!"
                text: qsTrId("sailfinder-oops")
                //% "Something went wrong, please try again later"
                hintText: qsTrId("sailfinder-error")
            }
        }

        BusyIndicator {
            id: tinderLogin
            size: BusyIndicatorSize.Large
            anchors.centerIn: parent
            running: Qt.application.active && visible
        }
    }
}

