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

Item {
    anchors.fill: parent

    Component.onCompleted: {
        try {
            numberOfMatches.text = api.matchesList.numberOfMatches()
        }
        catch(err) {
            console.debug("Matches cover data not ready yet")
        }
    }

    Connections {
        target: api
        onMatchesListChanged: {
            console.debug("Cover number of matches=" + api.matchesList.numberOfMatches())
            numberOfMatches.text = api.matchesList.numberOfMatches()
        }
    }

    Column {
        width: parent.width
        anchors.centerIn: parent

        TextLabel {
            id: numberOfMatches
            horizontalAlignment: Text.AlignHCenter
            font.pixelSize: Theme.fontSizeExtraLarge
            font.bold: true
            visible: text.length > 0
        }


        TextLabel {
            horizontalAlignment: Text.AlignHCenter
            font.pixelSize: Theme.fontSizeExtraLarge
            //% "Matches"
            text: qsTrId("sailfinder-matches")
            font.bold: numberOfMatches.text.length == 0 // no matches yet
        }
    }
}
