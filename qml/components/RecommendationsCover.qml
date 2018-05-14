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
            background.source = api.recommendation.photos.getPhoto(0).url
            name.text = api.recommendation.name
            distance.text = api.recommendation.distance + " km"
        }
        catch(err) {
            console.debug("Recommendations cover data not ready yet")
        }
    }

    Connections {
        target: api
        onRecommendationChanged: {
            background.source = api.recommendation.photos.getPhoto(0).url
            name.text = api.recommendation.name
            distance.text = api.recommendation.distance + " km"
        }
    }

    Image {
        id: background
        anchors.fill: parent
        asynchronous: true
        opacity: progress/3 // background
        Behavior on opacity { FadeAnimator {} }
        onStatusChanged: {
            if(status == Image.Error) {
                console.warn("Can't load image as cover background")
            }
        }
    }

    Column {
        anchors.centerIn: parent
        width: parent.width

        TextLabel {
            id: name
            horizontalAlignment: Text.AlignHCenter
            font.pixelSize: Theme.fontSizeExtraLarge
            font.bold: true
        }

        TextLabel {
            id: distance
            horizontalAlignment: Text.AlignHCenter
            font.pixelSize: Theme.fontSizeLarge
        }
    }

    CoverActionList {
        iconBackground: true

        CoverAction {
            iconSource: "../resources/images/dislike.png"
            onTriggered: api.passUser(api.recommendation.id)
        }

        CoverAction {
            iconSource: "../resources/images/like.png"
            onTriggered: api.likeUser(api.recommendation.id)
        }
    }
}
