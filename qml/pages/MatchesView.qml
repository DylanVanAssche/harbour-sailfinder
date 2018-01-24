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
import Harbour.Sailfinder.SFOS 1.0
import "../components"
import "../js/util.js" as Util

SilicaFlickable {
    property bool _intialFetchRequired: true
    signal headerChanged(string text)

    width: parent.width
    height: parent.height

    SFOS {
        id: sfos
    }

    Connections {
        target: api
        onMatchesListChanged: {
            matchesListView.model = api.matchesList
            headerChanged(Util.createHeaderMatches(matchesListView.count))
            noMatchesText.enabled = matchesListView.count == 0
            _intialFetchRequired = false
        }

        onNewMatch: {
            if(count == 1) {
                sfos.createNotification(
                            //% "New match!"
                            qsTrId("sailfinder-new-match"),
                            //% "You have received a new match! Go say hi!"
                            qsTrId("sailfinder-new-match-hint"),
                            "social",
                            "sailfinder-new-match"
                            )
            }
            else {
                sfos.createNotification(
                            //% "New matches!"
                            qsTrId("sailfinder-new-matches"),
                            //% "You have received %L0 new matches! Go say hi!"
                            qsTrId("sailfinder-new-matches-hint").arg(count),
                            "social",
                            "sailfinder-new-match"
                            )
            }
            api.getMatchesAll()
        }

        onUpdatesReady: {
            // Wait for refetch or do intial fetch when updates are received
            // Avoiding double intial fetch when updates are received at launch
            if(refetch || _intialFetchRequired) {
                console.debug("Matches or Blocks updated, refetching...")
                api.getMatchesAll()
            }
        }
    }

    SilicaListView {
        id: matchesListView
        anchors.fill: parent
        delegate: ContactsDelegate {
            id: contact
            width: ListView.view.width
            onRemoved: api.unmatch(model.matchId)
            onClicked: pageStack.push(Qt.resolvedUrl("MessagingPage.qml"), { matchObject: model.messages })
            menu: ContextMenu {
                MenuItem {
                    //% "Unmatch"
                    text: qsTrId("sailfinder-unmatch")
                    onClicked: contact.remove()
                }
            }
        }

        VerticalScrollDecorator {}
    }

    ViewPlaceholder {
        id: noMatchesText
        anchors.centerIn: parent
        //% "No matches!"
        text: qsTrId("sailfinder-no-matches")
        //% "Swipe on some recommendations"
        hintText: qsTrId("sailfinder-no-matches-text")
        enabled: false
    }
}
