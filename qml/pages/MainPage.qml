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
//import Nemo.DBus 2.0
import org.nemomobile.dbus 2.0
import Harbour.Sailfinder.SFOS 1.0
import "../components"
import "../js/util.js" as Util

Page {
    SilicaFlickable {
        anchors.fill: parent
        contentHeight: Screen.height

        PullDownMenu {
            busy: api.busy

            MenuItem {
                //% "About"
                text: qsTrId("sailfinder-about")
                onClicked: pageStack.push(Qt.resolvedUrl("AboutPage.qml"))
            }
        }

        PageHeader {
            id: header
            title: {
                switch(swipeView.currentIndex) {
                case 0:
                    return swipeView._recommendationsHeader;
                case 1:
                    return swipeView._matchesHeader;
                case 2:
                    return swipeView._profileHeader;
                default:
                    return "Unknown header";
                }
            }

            BusyIndicator {
                anchors {
                    left: parent.left
                    leftMargin: Theme.horizontalPageMargin
                    verticalCenter: parent.verticalCenter
                }
                size: BusyIndicatorSize.Small
                running: Qt.application.active && api.busy
            }
        }

        SFOS {
            id: sfos
        }

        DBusAdaptor {
            service: sfos.appName.replace("-", ".")
            iface: sfos.appName.replace("-", ".")
            path: "/"
            xml: '  <interface name="' + sfos.appName.replace("-", ".") + '">\n' +
                 '    <method name="activate" />\n' +
                 '  </interface>\n'

            function activate(category) {
                if(category == "sailfinder-new-match") {
                    swipeView.currentIndex = 1;
                    app.activate();
                    console.debug("Notification activation: " + category);
                }
                if(category == "sailfinder-new-message") {
                    swipeView.currentIndex = 1;
                    app.activate();
                    console.debug("Notification activation: " + category);
                }
                else {
                    console.warn("Notification activation doesn't match with our categories: " + category);
                }
            }
        }

        SlideshowView {
            //% "Recommendations"
            property string _recommendationsHeader: qsTrId("sailfinder-recommendations")
            //% "Matches"
            property string _matchesHeader: qsTrId("sailfinder-matches")
            //% "Profile"
            property string _profileHeader: qsTrId("sailfinder-profile")

            id: swipeView
            itemWidth: width
            itemHeight: height
            clip: true
            anchors {
                left: parent.left
                right: parent.right
                top: header.bottom
                bottom: bar.top
            }
            model: VisualItemModel {
                RecommendationsView {
                    onHeaderChanged: swipeView._recommendationsHeader = text
                }
                MatchesView {
                    onHeaderChanged: swipeView._matchesHeader = text
                }
                ProfileView {
                    onHeaderChanged: swipeView._profileHeader = text
                }
            }
        }

        NavigationBar {
            id: bar
            anchors.bottom: parent.bottom
            currentIndex: swipeView.currentIndex
            onNewIndex: swipeView.currentIndex = index
        }
    }
}
