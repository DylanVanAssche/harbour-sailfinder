/*
  Copyright (C) 2013 Jolla Ltd.
  Contact: Thomas Perl <thomas.perl@jollamobile.com>
  All rights reserved.

  You may use this file under the terms of BSD license as follows:

  Redistribution and use in source and binary forms, with or without
  modification, are permitted provided that the following conditions are met:
    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer in the
      documentation and/or other materials provided with the distribution.
    * Neither the name of the Jolla Ltd nor the
      names of its contributors may be used to endorse or promote products
      derived from this software without specific prior written permission.

  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
  ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
  WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
  DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDERS OR CONTRIBUTORS BE LIABLE FOR
  ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
  (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
  LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
  ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

import QtQuick 2.2
import Sailfish.Silica 1.0
import io.thp.pyotherside 1.3
//import org.nemomobile.keepalive 1.1
import QtPositioning 5.2


Page {
    id: page

    property var swipeLeftEnabled: true
    property var swipeRightEnabled: true
    property var hintsEnabled: false
    property var updateState: "None"
    property var superLikeLimit: false
    property var counter: 0
    property var reconnectCounter: 0

    Timer {
        id: hints
        interval: 1000*5.25
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered:
        {
            if(hintsEnabled)
            {
                switch(counter) {
                case 0:
                    // Show the tap hint.
                    labelHint.visible = true;
                    labelHint.text = "Hold for more info";
                    tapHint.visible = true;
                    tapHint.start();
                    counter++;
                    break;

                case 1:
                    // Show the swipe hint.
                    tapHint.visible = false;
                    tapHint.stop();
                    swipeHint.visible = true;
                    swipeHint.start();
                    labelHint.text = "Swipe through pictures";
                    counter++;
                    break;

                case 2:
                    // Show the user how to disable the hints.
                    swipeHint.visible = false;
                    swipeHint.stop();
                    labelHint.text = "Disable hints in Settings";
                    counter++;
                    break;
                case 3:
                    // Stop the hints.
                    labelHint.text = "Sailfinder hints";
                    labelHint.visible = false;
                    counter++;
                    break;

                default:
                    // Reset.
                    counter = 0;
                    hintsEnabled = false;
                }
            }
            else
            {
                // Hints are disabled so hide everthing and stop the timer.
                hints.stop();
                tapHint.visible = false;
                swipeHint.visible = false;
                labelHint.visible = false;
            }
        }
    }

    // Stop the GPS after 30 seconds of inactivity to save battery.
    Timer {
        id: controlGPSStatus
        interval: 30*1000
        running: false
        repeat: true
        onTriggered:
        {
            positionSource.active = false
        }
    }

    // Get the current GPS position and sync it with Tinder through Python.
    Item {
        id: gpsData
        property alias positionSource: positionSource
        PositionSource {
            id: positionSource
            updateInterval: 15 * 60 * 1000
            active: false
            onPositionChanged:
            {
                python.call('tinder.updateLocation',[positionSource.position.coordinate.latitude, positionSource.position.coordinate.longitude], function(latitude, longitude) {});
                console.log("LAT: " + positionSource.position.coordinate.latitude + " LONG: " + positionSource.position.coordinate.longitude)
                console.log('Updating position')
            }
        }
    }

    // Reconnect when the API doesn't respond.
    Timer {
        id: reconnect
        interval: 1000
        running: false
        repeat: true
        onTriggered:
        {
            switch(reconnectCounter)
            {
                case 7:
                    // Show the reconnect bar and hide the messages text.
                    reconnectBar.visible = true;
                    reconnectCounter++;
                    message.text = "";
                    message.hintText = "";
                    break;

                case 22:
                    // We passed 15 seconds, load the new people again and hide it again.
                    python.call('tinder.loadNewPeople',[], function() {});
                    python.call('tinder.loadPerson',[0, 0, true], function(pictureNumber, personsNumber, firstPass) {});
                    reconnectBar.visible = false;
                    reconnect.stop();
                    reconnectCounter = 0;
                    reconnectBar.value = 0;
                    break;

                default:
                    // Update the progressbar.
                    reconnectBar.value = (reconnectCounter - 7) * 6.6667;
                    reconnectCounter++;
                    break;
            }
        }
    }

    SilicaFlickable {
        anchors.fill: parent
        contentHeight: column.height

        Column {
            id: column
            width: page.width
            spacing: Theme.paddingLarge

            PullDownMenu {
                id: pullDownMenu

                MenuItem {
                    id: aboutPulleyMenu
                    text: "About"
                    onClicked:
                    {
                        // Open the About page.
                        pageStack.push(Qt.resolvedUrl('AboutPage.qml'));
                    }
                }

                MenuItem {
                    id: settingsPulleyMenu
                    text: "Settings"
                    onClicked:
                    {
                        // Open the Settings page and load the profile data.
                        pageStack.push(Qt.resolvedUrl('SettingsPage.qml'));
                    }
                }

                MenuItem {
                    id: profilePulleyMenu
                    text: "Profile"
                    onClicked:
                    {
                        // Open the Profile page and load the profile data.
                        pageStack.push(Qt.resolvedUrl('ProfilePage.qml'));
                    }
                }

                MenuItem {
                    id: savedPeoplePulleyMenu
                    text: "Saved people"
                    visible: false
                    onClicked:
                    {
                        // Open the SavedPeople page and load the saved people data.
                        pageStack.push(Qt.resolvedUrl('SavedPeoplePage.qml'));
                    }
                }

                MenuItem {
                    id: matchesPulleyMenu
                    text: "Matches"
                    onClicked:
                    {
                        // Open the Matches page and load the matches data.
                        pageStack.push(Qt.resolvedUrl('MatchesPage.qml'));
                    }
                }
            }

            PageHeader {
                id: pageHeader
                title: qsTr("Sailfinder")
            }

            ViewPlaceholder {
                id: message
                enabled: false
                text: "Out of likes!"
                hintText: "Please come back later..."

                ProgressBar {
                    id: reconnectBar
                    width: parent.width
                    anchors.centerIn: parent
                    visible: false
                    indeterminate: true
                    label: "Reconnecting in: " + progressValue + " seconds"
                }
            }

            Rectangle {
                width: Screen.width
                height: Screen.width
                color: "transparent"
                anchors
                {
                    left: parent.left
                    right: parent.right
                    leftMargin: Theme.horizontalPageMargin
                    rightMargin: Theme.horizontalPageMargin
                }

                BusyIndicator {
                    id: loadingPicture
                    anchors.centerIn: parent
                    size: BusyIndicatorSize.Large
                    running: true
                    visible: false
                }

                MouseArea {
                    id: gesturesPicture
                    width: Screen.width
                    height: Screen.width
                    anchors.horizontalCenter: parent.horizontalCenter
                    enabled: true
                    preventStealing: true // Other gestures from Sailfish OS are deactivated in this area.

                    property point origin
                    property var noGesture

                    Image {
                        id: picturePersons
                        width: parent.width
                        height: parent.height
                        source: "../images/noImage.png";
                        fillMode: Image.PreserveAspectFit
                        visible: false
                        onStatusChanged:
                        {
                            if (status == Image.Error)
                            {
                                source = "../images/noImage.png"
                                console.log('ERROR: pictureloading failed')
                            }
                        }
                    }

                    onPressAndHold:
                    {
                        pageStack.push(Qt.resolvedUrl('AboutPersonPage.qml'));
                        python.call('tinder.loadAbout',['person', 0], function(aboutType, matchNumber) {});
                        noGesture = true
                    }

                    onPressed:
                    {
                        origin = Qt.point(mouse.x, mouse.y)
                        noGesture = false
                    }

                    onReleased: {
                        if(!noGesture)
                        {
                            if(swipeLeftEnabled)
                            {
                                if (mouse.x - origin.x > 4)
                                {
                                    python.call('tinder.loadPerson',[2, 0, false], function(pictureNumber, personsNumber, firstPass) {});
                                    loadingPicture.visible = true;
                                    picturePersons.visible = false;
                                }
                            }

                            if(swipeRightEnabled)
                            {
                                if (mouse.x - origin.x < -4)
                                {
                                    python.call('tinder.loadPerson',[1, 0, false], function(pictureNumber, personsNumber, firstPass) {});
                                    loadingPicture.visible = true;
                                    picturePersons.visible = false;
                                }
                            }
                        }
                    }
                }

                TapInteractionHint {
                    // 2,625 sec/tap
                    id: tapHint
                    anchors.centerIn: parent
                    visible: false
                    loops: 2
                }

                TouchInteractionHint {
                    // 1,75 sec/swipe
                    id: swipeHint
                    anchors.centerIn: parent
                    direction: TouchInteraction.Left
                    visible: false
                    loops: 3
                }
            }

            // Spacer
            Rectangle {
                width: parent.width
                height: Screen.width/25
                color: "transparent";
            }

            Row {
                id: likeDislikeSuperLike
                anchors.horizontalCenter: parent.horizontalCenter
                visible: false
                spacing: Theme.paddingLarge


                IconButton {
                    id: dislike
                    icon.source: {
                        if (Screen.width < 600)
                        {
                            "../images/dislike_small.png"
                        }
                        else
                        {
                            "../images/dislike_large.png"
                        }
                    }
                onClicked:
                    {
                        dislike.enabled = false;
                        superLike.enabled = false;
                        like.enabled = false;
                        python.call('tinder.likeDislikeSuperlikePerson',[1], function(action) {});
                    }
                }

                // Spacer
                Rectangle {
                    width: Screen.width/18
                    height: parent.height
                    color: "transparent"
                }

                IconButton {
                    id: superLike
                    icon.source: {
                        if (Screen.width < 600)
                        {
                            "../images/superLike_small.png"
                        }
                        else
                        {
                            "../images/superLike_large.png"
                        }
                    }
                    onClicked:
                    {
                        dislike.enabled = false;
                        superLike.enabled = false;
                        like.enabled = false;
                        python.call('tinder.likeDislikeSuperlikePerson',[3], function(action) {});
                    }
                }

                // Spacer
                Rectangle {
                    width: Screen.width/18
                    height: parent.height
                    color: "transparent"
                }

                IconButton {
                    id: like
                    icon.source: {
                        if (Screen.width < 600)
                        {
                            "../images/like_small.png"
                        }
                        else
                        {
                            "../images/like_large.png"
                        }
                    }
                    onClicked:
                    {
                        dislike.enabled = false;
                        superLike.enabled = false;
                        like.enabled = false;
                        python.call('tinder.likeDislikeSuperlikePerson',[2], function(action) {});
                    }
                }
            }

            // Spacer
            Rectangle {
                width: parent.width
                height: 20
                color: "transparent"
            }

            Row {
                id: personDataRow
                spacing: Theme.paddingMedium
                anchors
                {
                    left: column.left
                    right: column.right
                    leftMargin: Theme.horizontalPageMargin
                    rightMargin: Theme.horizontalPageMargin
                }

                Label {
                    id: personData
                    color: Theme.highlightColor
                    text: ""
                }

                Image {
                    id: genderIcon
                    width: personData.height
                    height: personData.height
                    source: "../images/male.png"
                    visible: false
                }
            }

            Label {
                id: timeNewLikes
                anchors
                {
                    left: column.left
                    right: column.right
                    leftMargin: Theme.horizontalPageMargin
                    rightMargin: Theme.horizontalPageMargin
                }
                font.pixelSize: Theme.fontSizeSmall
                visible: false
                text: ""
            }

            Label {
                id: bio
                text: ""
                visible: false
                font.pixelSize: Theme.fontSizeSmall
                wrapMode: Text.WordWrap
                anchors {
                    left: parent.left
                    right: parent.right
                    leftMargin: Theme.horizontalPageMargin
                    rightMargin: Theme.horizontalPageMargin
                }
            }

            // Spacer
            Rectangle {
                id: bioSpacer
                width: parent.width
                height: 20
                visible: false
                color: "transparent"
            }
        }
    }

    InteractionHintLabel {
        id: labelHint
        anchors.bottom: parent.bottom
        visible: false
        text: "Sailfinder hints"
    }

    /*BackgroundJob {
        // Check for new users or count down out of likes timer in background.
        id: updater
        frequency: BackgroundJob.FifteenMinutes
        enabled: false
        onTriggered:
        {
            update();
        }
    }*/

    Timer {
        // Check for new users or count down out of likes timer in background.
        id: updater
        interval: 15 * 60 * 1000
        onTriggered:
        {
            update();
        }
    }

    function update()
    {
        // Check for new likes.
        if(updateState == "OutOfLikes")
        {
            console.log("UPDATE: Out of likes");
            python.call('tinder.loadPerson',[0, 0, true], function(pictureNumber, personsNumber, firstPass) {});
        }

        // Check for new users.
        if(updateState == "OutOfUsers")
        {
            console.log("UPDATE: Out of users");
            python.call('tinder.loadNewPeople',[], function() {});
            python.call('tinder.loadPerson',[0, 0, true], function(pictureNumber, personsNumber, firstPass) {});
        }

        // Sync the cover.
        python.call('tinder.cover',[0, false], function(pageNumber, pushNecessary) {});

        updater.finished()
    }

    Python {
        id: python
        Component.onCompleted:
        {
            // Add the Python path to PyOtherSide and import our module 'tinder'.
            addImportPath(Qt.resolvedUrl('.'));
            importModule('tinder', function() {});

            // When Python is ready, load the users...
            python.call('tinder.loadNewPeople',[], function() {});
            python.call('tinder.loadPerson',[0, 0, true], function(pictureNumber, personsNumber, firstPass) {});
            python.call('tinder.updateInterval',[], function() {});
            python.call('tinder.hintsHandler',[0], function() {});

            // Python is ready, start the controlGPSStatus timer.
            controlGPSStatus.start();

            setHandler('getDataMain', function(name, age, gender, distance)
            {
                // Data about the person and the gender
                personData.text = name + ' ('+ age + ')' + ' - ' + distance + ' km away';
                personData.visible = true;
                if(gender == 'male')
                {
                    genderIcon.source = "../images/male.png"
                }
                else
                {
                    genderIcon.source = "../images/female.png"
                }
                genderIcon.visible = true;

                // Buttons
                likeDislikeSuperLike.visible = true;
                like.enabled = true;
                if(!superLikeLimit) {
                    superLike.enabled = true;
                }
                dislike.enabled = true;

                // We have users and we have likes remaining so deactivate the messages 'no likes' and 'no users'.
                timeNewLikes.visible = false;
                message.enabled = false;

                // Updater status: None.
                updateState = "None"

                // Only activate our hints when we have users to like.
                if(hintsEnabled)
                {
                    hints.start();
                }

                // Tinder API is ready to receive position updates.
                positionSource.active = true

                // Reconnecting is not necesarry anymore.
                reconnect.stop();
                reconnectBar.visible = false;
                reconnectCounter = 0;

                // Hide bio, if enabled we will show it again later.
                bio.visible = false;
                bioSpacer.visible = false;
            });

            setHandler('getBio', function(bioData)
            {
                if(bioData != '')
                {
                    bio.text = bioData;
                    bio.visible = true;
                    bioSpacer.visible = true;
                }
            });

            setHandler('getPersonPicture', function(url)
            {
                // Get the picture URL and enable the gestures.
                picturePersons.source = url;
                picturePersons.visible = true;
                loadingPicture.visible = false;
                gesturesPicture.enabled = true;
            });

            setHandler('canLikeIn', function(time)
            {
                // Show the time before we get new likes and the 'no likes' message.
                personData.text = "New likes in:";
                personData.visible = true;
                genderIcon.visible = false;
                timeNewLikes.text = time;
                timeNewLikes.visible = true;
                message.enabled = true;
                message.text = "Out of likes :(";
                message.hintText = "Please come back later...";

                // Hide the pictures, disable the swipe gestures and the buttons.
                picturePersons.visible = false;
                loadingPicture.visible = false;
                gesturesPicture.enabled = false;
                likeDislikeSuperLike.visible = false;

                // Stop the hints and hide them.
                hints.stop();
                tapHint.visible = false;
                swipeHint.visible = false;
                labelHint.visible = false;

                // Updater status: OutOfLikes.
                updateState = "OutOfLikes"

                // Start the updater to check for updates.
                //updater.enabled = true
                updater.start();

                // Reconnecting not necesarry.
                reconnect.stop();
            });

            // Check if we matched and show then the NewMatchPage
            setHandler('resultAction', function(result)
            {
                if(result == true)
                {
                    // Show the NewMatchPage on a match and load the user data from that match.
                    appWindow.activate();
                    pageStack.completeAnimation();
                    pageStack.replace(Qt.resolvedUrl('NewMatchPage.qml'));
                    pageStack.completeAnimation();
                }

                if(result == 'outOfSuperLikes')
                {
                    superLike.enabled = false;
                    superLikeLimit = true;
                }
                console.log(result);
            });

            // Activate and deactivate the right swipe directions... This is a workaround for the SlideshowView component who isn't very nice for internet images.
            setHandler('getPersonPictureNavigation', function(state)
            {
                switch(state)
                {
                    // End of the fotostream
                case 1:
                    swipeLeftEnabled = true;
                    swipeRightEnabled = false;
                    break;

                    // Begin of the fotostream.
                case 2:
                    swipeLeftEnabled = false;
                    swipeRightEnabled = true;
                    break;

                    // Only one picture available.
                case 3:
                    swipeLeftEnabled = false;
                    swipeRightEnabled = false;
                    break;

                    // In fotostream.
                case 4:
                    swipeLeftEnabled = true;
                    swipeRightEnabled = true;
                    break;
                }
            });

            // Set the correct update interval based on the user settings.
            setHandler('getUpdateInterval', function(dataUpdateIntervalValue, gpsUpdateIntervalValue)
            {
                if(dataUpdateIntervalValue == 0)
                {
                    //updater.frequency = BackgroundJob.FifteenMinutes
                    updater.interval = 15 * 60 * 1000
                }

                if(dataUpdateIntervalValue == 1)
                {
                    //updater.frequency = BackgroundJob.ThirtyMinutes
                    updater.interval = 30 * 60 * 1000
                }

                if(dataUpdateIntervalValue == 2)
                {
                    //updater.frequency = BackgroundJob.OneHour
                    updater.interval = 60 * 60 * 1000
                }

                if(dataUpdateIntervalValue == 3)
                {
                    //updater.frequency = BackgroundJob.TwoHours
                    updater.interval = 120 * 60 * 1000
                }

                if(dataUpdateIntervalValue == 4)
                {
                    //updater.frequency = BackgroundJob.FourHours
                    updater.interval = 240 * 60 * 1000
                }

                positionSource.updateInterval = gpsUpdateIntervalValue * 60 * 1000
            });

            // Get the hintstate from Python.
            setHandler('getHintsStateMain', function(hintsState)
            {
                if(hintsState)
                {
                    hintsEnabled = true;
                }
                else
                {
                    hintsEnabled = false;
                    swipeHint.visible = false;
                    tapHint.visible = false;
                    labelHint.visible = false;
                }
            });

            setHandler('loadingNewPeople', function(state)
            {
                if(state)
                {
                    // Hide everthing.
                    picturePersons.visible = false;
                    likeDislikeSuperLike.visible = false;
                    personData.visible = false;
                    genderIcon.visible = false;
                    bio.visible = false;
                    bioSpacer.visible = false;

                    // Show the message 'Loading new people'.
                    message.enabled = true;
                    message.text = "Loading new people";
                    message.hintText = "Please wait...";
                    reconnect.start();
                }
            });

            setHandler('noPeopleNearby', function(state) {
                if(state)
                {
                    // Show the user that we can't find any users.
                    message.enabled = true;
                    message.text = "No users :(";
                    message.hintText = "Extend your range or age.";

                    // Hide the pictures, disable the swipe gestures and the buttons.
                    personData.visible = false;
                    genderIcon.visible = false;
                    picturePersons.visible = false;
                    loadingPicture.visible = false;
                    gesturesPicture.enabled = false;
                    likeDislikeSuperLike.visible = false;

                    // Stop the hints and hide them.
                    hints.stop();
                    tapHint.visible = false;
                    swipeHint.visible = false;
                    labelHint.visible = false;

                    // Updater status: "OutOfUsers".
                    updateState = "OutOfUsers"

                    // Start the updater to check for updates.
                    //updater.enabled = true
                    updater.start();

                    // Reconnecting not necesarry.
                    reconnect.stop();

                    console.log("No users nearby...")
                }
            });

            // API Error, I can't do anything about it but show the user that the API isn't working.
            setHandler('error', function(firstLine, secondLine)
            {
                message.text = firstLine
                message.hintText = secondLine
                console.log('Python ERROR: ' + traceback)
            });
        }

        onError:
        {
            console.log('Python ERROR: ' + traceback);
            Clipboard.text = traceback
            pageStack.completeAnimation();
            pageStack.replace(Qt.resolvedUrl('ErrorPage.qml'));
            pageStack.completeAnimation();
        }

        //DEBUG
        /*
        onReceived:
        {
            console.log('Python MESSAGE: ' + data);
        }*/
    }
}
