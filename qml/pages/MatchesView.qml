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
    signal header(string text)

    width: parent.width
    height: parent.height
    Component.onCompleted: api.getMatchesAll()

    SFOS {
        id: sfos
    }

    Connections {
        target: api
        onMatchesListChanged: {
            matchesListView.model = api.matchesList
            header(Util.createHeaderMatches(matchesListView.count))
        }
        onNewMatch: {
            sfos.createNotification(
                        //% "New match!"
                        qsTrId("sailfinder-new-match"),
                        //% "You have received a new match! Go say hi!"
                        qsTrId("sailfinder-new-match-hint"),
                        "social",
                        "sailfinder-new-match"
                        )
            api.getMatchesAll();
        }
    }

    SilicaListView {
        id: matchesListView
        anchors.fill: parent
        delegate: ContactsDelegate {
            id: contact
            width: ListView.view.width
            onRemoved: api.unmatch(model.matchId)
            menu: ContextMenu {
                MenuItem {
                    //% "Unmatch"
                    text: qsTrId("sailfinder-unmatch")
                    onClicked: contact.remove()
                }
            }
        }
    }
}
