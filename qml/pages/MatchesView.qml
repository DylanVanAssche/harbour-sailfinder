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
    property string _userId
    signal headerChanged(string text)

    id: matches
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
            busyStatus.running = false
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
        }

        onNewMessage: {
            // When new messages are received count is > 0
            // When we send a message then count == 0
            if(count == 1) {
                sfos.createNotification(
                            //% "New message!"
                            qsTrId("sailfinder-new-message"),
                            //% "You have received a new message!"
                            qsTrId("sailfinder-new-message-hint"),
                            "social",
                            "sailfinder-new-message"
                            )
            }
            else if(count > 1){
                sfos.createNotification(
                            //% "New messages!"
                            qsTrId("sailfinder-new-messages"),
                            //% "You have received %L0 new messages!"
                            qsTrId("sailfinder-new-messages-hint").arg(count),
                            "social",
                            "sailfinder-new-message"
                            )
            }
        }

        onUpdatesReady: {
            // Wait for refetch or do intial fetch when updates are received
            // Avoiding double intial fetch when updates are received at launch
            console.debug("Refetch: " + refetch)
            console.debug("Initial fetch: " + _intialFetchRequired)
            if(refetch || _intialFetchRequired) {
                console.debug("Matches or Blocks updated, refetching...")
                api.getMatchesAll()
            }
        }

        onProfileChanged: {
            _userId = api.profile.id
        }
    }

    SilicaListView {
        id: matchesListView
        anchors.fill: parent
        delegate: ContactsDelegate {
            id: contact
            width: ListView.view.width
            onRemoved: api.unmatch(model.matchId)
            enabled: _userId.length > 0 // Only enable when all our data is received to send messages
            onClicked: pageStack.push(
                           Qt.resolvedUrl("MessagingPage.qml"),
                           {
                               name: model.name,
                               birthDate: model.birthDate,
                               gender: model.gender,
                               avatar: model.avatar,
                               matchId: model.matchId,
                               userId: matches._userId,
                               distance: -1, // distance and match will change when full profile API is added
                               match: model
                           }
                           )
            onAvatarClicked: pageStack.push(Qt.resolvedUrl("MatchProfilePage.qml"), {match: model})
            menu: ContextMenu {
                MenuItem {
                    //% "Profile"
                    text: qsTrId("sailfinder-profile")
                    onClicked: pageStack.push(Qt.resolvedUrl("MatchProfilePage.qml"), {match: model})
                }

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

    BusyIndicator {
        id: busyStatus
        anchors.centerIn: parent
        size: BusyIndicatorSize.Large
        running: Qt.application.active
    }
}
