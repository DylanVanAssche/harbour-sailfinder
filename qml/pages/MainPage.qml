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

            MenuItem {
                //% "Settings"
                text: qsTrId("sailfinder-settings")
                onClicked: pageStack.push(Qt.resolvedUrl("SettingsPage.qml"))
            }
        }

        PageHeader {
            id: header
            title: Util.header(swipeView.currentIndex)
        }

        SlideshowView {
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
                RecommendationsView {}
                MatchesView {}
                ProfileView {}
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
