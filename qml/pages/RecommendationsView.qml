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

SilicaFlickable {
    signal headerChanged(string text)

    width: parent.width
    height: parent.height
    contentHeight: exhaustedText.enabled? parent.height: column.height

    Timer {
        id: retryTimer
        interval: 10*60*1000
        repeat: true
        onTriggered: api.getRecommendations()
    }

    Connections {
        target: api
        onRecommendationChanged: {
            console.debug("Recommendation data received")
            photoList.photoListModel = api.recommendation.photos
            bio.text = api.recommendation.bio
            retryTimer.stop()
            recsBar.canSuperlike = api.canSuperlike
            recsBar.loaded = true
            column.visible = api.canLike
            exhaustedText.enabled = !api.canLike
            if(api.canLike) {
                headerChanged(Util.createHeaderRecs(api.recommendation.name, api.recommendation.birthDate, api.recommendation.gender, api.recommendation.distance))
            }
            else {
                //% "Recommendations"
                headerChanged(qsTrId("sailfinder-recommendations"))
            }
        }

        onRecommendationTimeOut: {
            console.warn("Recommendation timeout, retrying in 5 minutes...")
            retryTimer.start()
        }

        onHasRecommendationsChanged: {
            console.warn("Recommendation exhausted, showing placeholder...")
            column.visible = api.hasRecommendations
            exhaustedText.enabled = !api.hasRecommendations
            //% "Recommendations"
            headerChanged(qsTrId("sailfinder-recommendations"))
            retryTimer.start()
        }

        onProfileChanged: api.getRecommendations()
        onUnlockedAllEndpoints: recsBar.loaded = true // Reset UI on network or other failure
    }

    Column {
        id: column
        width: parent.width
        spacing: Theme.paddingLarge
        visible: true

        PhotoGridLayout {
            id: photoList
        }

        RecommendationsBar {
            id: recsBar
            onLiked: {
                loaded = false
                api.likeUser(api.recommendation.id)
                photoList.closeFullScreen()
            }
            onSuperliked: {
                loaded = false
                api.superlikeUser(api.recommendation.id)
                photoList.closeFullScreen()
            }
            onPassed: {
                loaded = false
                api.passUser(api.recommendation.id)
                photoList.closeFullScreen()
            }
        }

        TextArea {
            id: bio
            width: parent.width
            readOnly: true
            visible: text.length > 0
        }
    }

    ViewPlaceholder {
        id: exhaustedText
        anchors.centerIn: parent
        //% "Exhausted!"
        text: qsTrId("sailfinder-out-of-recs")
        //% "Please come back later"
        hintText: qsTrId("sailfinder-out-of-recs-text")
        enabled: false
    }
}
