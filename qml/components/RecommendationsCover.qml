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
    property bool _loaded
    property bool _canLike: true // avoid race condition at launch

    function populate() {
        if(api.recommendation !== "null") {
            background.source = api.recommendation.photos.getPhoto(0).url
            name.text = api.recommendation.name
            distance.text = api.recommendation.distance + " km"
            _canLike = api.canLike
            _loaded = true
        }
    }

    anchors.fill: parent

    Connections {
        target: api
        onRecommendationChanged: populate()
    }

    Image {
        id: background
        anchors.fill: parent
        asynchronous: true
        opacity: _canLike? progress/3: 0.0 // background
        Behavior on opacity { FadeAnimator {} }
        onStatusChanged: {
            if(status == Image.Error) {
                console.warn("Can't load image as cover background")
            }
        }
    }

    // Normal recommendations swiping
    Column {
        width: parent.width
        anchors.centerIn: parent 
        opacity: _canLike? 1.0: 0.0
        Behavior on opacity { FadeAnimator {} }

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

    BusyIndicator {
        anchors.centerIn: parent
        size: BusyIndicatorSize.Medium
        // Show loading indicator until the name of the recommendation has been loaded
        running: name.text.length == 0
    }

    // Exhausted swiping
    Column {
        width: parent.width
        anchors.centerIn: parent
        opacity: _canLike? 0.0: 1.0
        Behavior on opacity { FadeAnimator {} }

        Image {
            width: Theme.itemSizeSmall
            anchors.horizontalCenter: parent.horizontalCenter
            source: "qrc:///images/cover-logo.png"
        }

        TextLabel {
            horizontalAlignment: Text.AlignHCenter
            font.pixelSize: Theme.fontSizeLarge
            //% "Exhausted!"
            text: qsTrId("sailfinder-out-of-recs")
        }
    }

    CoverActionList {
        enabled: _loaded && app.swipeViewIndex === 0 && _canLike
        iconBackground: true

        CoverAction {
            iconSource: "../resources/images/dislike.png"
            onTriggered: {
                _loaded = false
                api.passUser(api.recommendation.id, api.recommendation.sNumber)
            }
        }

        CoverAction {
            iconSource: "../resources/images/like.png"
            onTriggered: {
                _loaded = false
                api.likeUser(api.recommendation.id, api.recommendation.sNumber)
            }
        }
    }
}
