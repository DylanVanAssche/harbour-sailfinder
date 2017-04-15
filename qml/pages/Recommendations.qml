import QtQuick 2.0
import Sailfish.Silica 1.0
import "js/recs.js" as Recs
import "js/util.js" as Util


SilicaFlickable {
    width: parent.width; height: parent.height
    contentHeight: recsColumn.height

    Connections {
        target: app
        onCachingRecsChanged: app.recsData? Recs.load(): console.error("[ERROR] Invalid recommendations data: " + app.recsData)
        onCleanup: Recs.clear()
        onRefreshRecs: Recs.get()
    }

    Connections {
        target: main

        onOutOfLikesChanged: {
            if(outOfLikes == true) {
                parameters.wasOutOfLikes = true
                toaster.previewBody = qsTr("Out of likes") + "!"
                toaster.publish()
                app.headerRecs = qsTr("Out of likes") + "!"
            }
        }

        onOutOfUsersChanged: {
            if(outOfUsers == true) {
                toaster.previewBody = qsTr("Out of users") + "!"
                toaster.publish()
                app.headerRecs = qsTr("Out of users") + "!"
            }
        }

        onOutOfSuperlikesChanged: {
            if(outOfSuperlikes == true) {
                toaster.previewBody = qsTr("Out of superlikes") + "!"
                toaster.publish()
            }
        }

        onDiscoveryChanged: (discovery && !outOfLikes)? undefined: app.headerRecs = qsTr("Undiscoverable") + "!"; // Discovery enabled?
    }

    VerticalScrollDecorator {}

    Column {
        id: recsColumn
        width: parent.width
        spacing: Theme.paddingLarge

        ImageGrid { id: userAvatars; show: !outOfLikes && !app.cachingRecs && discovery }

        ImageGridPlaceholder { show: outOfLikes; head: qsTr("You're out of likes") + "!"; description: qsTr("Please come back later to swipe on more people") + "." }

        ImageGridPlaceholder { show: app.cachingRecs; head: qsTr("Discovering") + "..."; description: qsTr("We're looking for new people for you right now") + "..." }

        ImageGridPlaceholder { show: !discovery; head: qsTr("Undiscoverable"); description: qsTr("Turn on discovery to swipe on people") + "." }

        ImageGridPlaceholder { show: outOfUsers; head: qsTr("You're out of users") + "!"; description: qsTr("There are no potential matches in your area, change your radius") + "." }

        Row {
            id: buttonRow
            height: Theme.iconSizeExtraLarge*1.2
            spacing: Theme.paddingLarge*3
            anchors { horizontalCenter: parent.horizontalCenter}
            opacity: (app.cachingRecs || app.loadingRecs || outOfLikes || !discovery)? 0.25: 1.0

            IconButton {
                id: dislikeButton
                anchors { verticalCenter: parent.verticalCenter}
                icon.source: "../resources/images/dislike.png"
                icon.scale: Theme.iconSizeExtraLarge/icon.width
                enabled: !app.cachingRecs && !app.loadingRecs && !outOfLikes && discovery
                onClicked: Recs.dislike()
            }

            IconButton {
                id: superlikeButton
                anchors { verticalCenter: parent.verticalCenter}
                icon.source: "../resources/images/superlike.png"
                icon.scale: Theme.iconSizeExtraLarge/icon.width
                enabled: !app.cachingRecs && !app.loadingRecs && !outOfSuperlikes && !outOfLikes && discovery
                opacity: outOfSuperlikes && buttonRow.opacity==1.0? 0.25: 1.0 // Avoid 2 times faded
                onClicked: Recs.superlike()
            }

            IconButton {
                id: likeButton
                anchors { verticalCenter: parent.verticalCenter}
                icon.source: "../resources/images/like.png"
                icon.scale: Theme.iconSizeExtraLarge/icon.width
                enabled: !app.cachingRecs && !app.loadingRecs && !outOfLikes && discovery
                onClicked: Recs.like()
            }
        }

        TextArea {
            id: bio
            width: parent.width
            readOnly: true
            wrapMode: TextEdit.Wrap
            label: qsTr("Biography")
            visible: text && settings.showBio && !outOfLikes && !app.cachingRecs && discovery
        }

        GlassButton { id: instagram; show: settings.showInstagram && !outOfLikes && !app.cachingRecs && discovery; iconSource: "../resources/images/icon-instagram.png"; itemScale: 0.5 }
        GlassButton { id: job; show: settings.showJob && !outOfLikes && !app.cachingRecs && discovery; iconSource: "../resources/images/icon-job.png"; itemScale: 0.5 }
        GlassButton { id: school; show: settings.showSchool && !outOfLikes && !app.cachingRecs && discovery; iconSource: "../resources/images/icon-school.png"; itemScale: 0.5 }
        /*GlassButton { id: spotify; show: settings.showSpotify && !outOfLikes && !app.cachingRecs && discovery; link: "https://www.spotify.com/"; iconSource: "../resources/images/icon-spotify.png"; iconText: "Spotify"; itemScale: 0.5 }*/ // Sailfinder V3.X
    }
}

