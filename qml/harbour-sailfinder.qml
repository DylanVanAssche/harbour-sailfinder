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
import Harbour.Sailfinder.API 1.0
import Harbour.Sailfinder.SFOS 1.0
import Nemo.DBus 2.0
import Nemo.Configuration 1.0
import "pages"

ApplicationWindow
{
    property bool networkStatus
    property int swipeViewIndex: 0

    Component {
        id: welcomePage
        WelcomePage {}
    }

    Component {
        id: termsPage
        TermsPage {}
    }

    id: app
    initialPage: temp.readTerms? welcomePage: termsPage
    cover: Qt.resolvedUrl("pages/CoverPage.qml")
    allowedOrientations: defaultAllowedOrientations
    onNetworkStatusChanged: {
        if(networkStatus == false) {
            //% "Network connection failure"
            sfos.createToaster(qsTrId("sailfinder-not-connected"), "icon-s-high-importance", "sailfinder-network")
        }
    }

    readonly property string accountkitAuthUrl: "https://www.accountkit.com/v1.1/dialog/sms_login/?app_id=464891386855067&display=modal&fb_app_events_enabled=true&locale=en_GB&logging_ref=f22d4aceb9428&origin=https%3A%2F%2Ftinder.com&redirect=&sdk=web&state=csrf"
    readonly property string fbAuthUrl: "https://m.facebook.com/login.php?skip_api_login=1&api_key=464891386855067&signed_next=1&next=https%3A%2F%2Fm.facebook.com%2Fv2.8%2Fdialog%2Foauth%3Fchannel%3Dhttps%253A%252F%252Fstaticxx.facebook.com%252Fconnect%252Fxd_arbiter%252Fr%252FlY4eZXm_YWu.js%253Fversion%253D42%2523cb%253Df2ef0d47f1ab162%2526domain%253Dtinder.com%2526origin%253Dhttps%25253A%25252F%25252Ftinder.com%25252Ff1a5e2552acd812%2526relation%253Dopener%26redirect_uri%3Dhttps%253A%252F%252Fstaticxx.facebook.com%252Fconnect%252Fxd_arbiter%252Fr%252FlY4eZXm_YWu.js%253Fversion%253D42%2523cb%253Df3e527820f87b8a%2526domain%253Dtinder.com%2526origin%253Dhttps%25253A%25252F%25252Ftinder.com%25252Ff1a5e2552acd812%2526relation%253Dopener%2526frame%253Df3c57eb25aa9564%26display%3Dtouch%26scope%3Duser_birthday%252Cuser_photos%252Cuser_education_history%252Cemail%252Cuser_relationship_details%252Cuser_friends%252Cuser_work_history%252Cuser_likes%26response_type%3Dtoken%252Csigned_request%26domain%3Dtinder.com%26origin%3D2%26client_id%3D464891386855067%26ret%3Dlogin%26sdk%3Djoey%26logger_id%3D2ae3adb2-6198-e6b6-452e-e3f58a61ccea&cancel_url=https%3A%2F%2Fstaticxx.facebook.com%2Fconnect%2Fxd_arbiter%2Fr%2FlY4eZXm_YWu.js%3Fversion%3D42%23cb%3Df3e527820f87b8a%26domain%3Dtinder.com%26origin%3Dhttps%253A%252F%252Ftinder.com%252Ff1a5e2552acd812%26relation%3Dopener%26frame%3Df3c57eb25aa9564%26error%3Daccess_denied%26error_code%3D200%26error_description%3DPermissions%2Berror%26error_reason%3Duser_denied%26e2e%3D%257B%257D&display=touch&locale=nl_NL&logger_id=2ae3adb2-6198-e6b6-452e-e3f58a61ccea&_rdr"
    readonly property string fbUserAgent: "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/535.19 (KHTML, like Gecko) Chrome/18.0.1025.45 Safari/535.19"
    readonly property real fadeOutValue: 0.2

    API {
        id: api
    }

    SFOS {
        id: sfos
    }

    ConfigurationGroup {
        id: settings
        path: "/apps/harbour-sailfinder/settings"
    }

    ConfigurationGroup {
        id: temp
        path: "/apps/harbour-sailfinder/temp"

        property date lastActivityDate: new Date()
        property bool readTerms: false
        Component.onCompleted: console.debug("Last activity date:" + temp.lastActivityDate)
    }

    DBusInterface {
        bus: DBus.SystemBus
        service: "net.connman"
        path: "/"
        iface: "net.connman.Manager"
        signalsEnabled: true
        Component.onCompleted: getStatus() // Init

        // Methods
        function getStatus() {
            typedCall("GetProperties", [], function(properties) {
                if(properties["State"] == "online") {
                    networkStatus = true
                }
                else {
                    networkStatus = false
                }
            },
            function(trace) {
                console.error("Network state couldn't be retrieved: " + trace)
            })
        }

        // Signals
        function propertyChanged(name, value) {
            if(name == "State") {
                if(value == "online") {
                    networkStatus = true
                }
                else {
                    networkStatus = false
                }
            }
        }
    }
}

