import QtQuick 2.2
import Sailfish.Silica 1.0
import io.thp.pyotherside 1.3
import "../pages/lib/helper.js" as Helper

Page {

    onStatusChanged:
    {
        if(status == PageStatus.Active)
        {
            if(matchesModel.count > 1)
            {
                cover_data.text = matchesModel.count + qsTr(" matches")
            }
            else
            {
                cover_data.text = matchesModel.count + qsTr(" match")
            }
            cover_data.image = '../images/matches.png'
            cover_data.text_enabled = true
            cover_data.image_enabled = true
            cover_data.actions_enabled = false
        }
    }

    Component.onDestruction:
    {
        var date = new Date();
        python.call('api.last_activity',[date.toISOString()], function(last_activity_ISO_format) {});
    }

    property bool new_messages
    property var number_of_messages
    property var last_active
    property int last_message_counter
    property bool last_message_found

    // Sailfinder API data
    property var personID
    property var matchID
    property var name
    property var bio
    property var age
    property var birth_date
    property var gender
    property var photos
    property var common_friends_count
    property var common_like_count
    property var super_like
    property var dead
    property var last_message_date
    property var last_activity_date
    property var messages

    function loadMatches(matches)
    {
        for (var i = 0; i < Object.keys(matches).length; i++)
        {
            try {
                personID = matches[i]['person']['_id']
                name = matches[i]['person']['name']
                bio = matches[i]['person']['bio']
                gender = matches[i]['person']['gender']
                birth_date = matches[i]['person']['birth_date']
                photos = matches[i]['person']['photos']
                super_like = matches[i]['is_super_like']
                dead = matches[i]['dead']
                common_friends_count = matches[i]['common_friend_count']
                common_like_count = matches[i]['common_like_count']
                messages = matches[i]['messages']
                number_of_messages = matches[i]['messages'].length // Get last message data
                last_activity_date = matches[i]['last_activity_date']

                try
                {
                    matchID = matches[i]['id']
                    last_message_counter = Object.keys(messages).length-1 // New person!
                    last_message_found = false

                    while(messages[last_message_counter]['from'] == personID) // Own messages are not counted as new messages!
                    {
                        last_message_date = messages[last_message_counter]['sent_date']
                        last_message_counter--
                    }

                    new_messages = Helper.time_difference(last_message_date, last_active)
                    //console.log("[DEBUG] Last message from user: " + name + ': ' + last_message_date)
                }
                catch(err)
                {
                    console.log("[INFO] No messages for this match: " + name)
                    new_messages = false
                }

                age = Helper.calculate_age(birth_date);

                matchesModel.append({url: photos[0]['url'], name: name, super_like: super_like, new_messages: new_messages, messages: messages, last_active: last_activity_date, ID: personID, matchID: matchID, photos: photos, gender: gender, bio: bio, age: age}) // Everything ready, add it to the list
            }
            catch(err)
            {
                console.log("[ERROR] Loading match: " + i + "failed: " + err)
            }
        }

        // Update cover
        cover_data.text = matchesModel.count + qsTr(" matches")
        cover_data.image = '../images/matches.png'
        cover_data.text_enabled = true
        cover_data.image_enabled = true
        cover_data.actions_enabled = false
    }

    SilicaFlickable {
        anchors.fill: parent
        contentHeight: pageColumn.height

        Column {
            id: pageColumn
            anchors.fill: parent

            RemorsePopup {
                id: remorse
            }

            PageHeader {
                id: header
                title: qsTr("People")
            }

            PullDownMenu {
                id: pullDownMenu

                MenuItem {
                    text: qsTr("Refresh")
                    onClicked:
                    {
                        // Refresh the people list:
                        matchesModel.clear()
                        message.text = qsTr("Refreshing...")
                        message.hintText = qsTr("A moment please")
                        message.enabled = true
                        matchesModel.clear()
                        python.call('api.last_activity',[''], function(empty) {});
                    }
                }
            }

            // Get all the matches and put them in a list.
            SilicaListView {
                width: parent.width
                height: Screen.height - header.height
                anchors.left: parent.left
                anchors.right: parent.right
                model: matchesModel
                quickScroll: true
                clip: true

                delegate: ListItem {
                    highlighted: model.new_messages
                    contentHeight: Theme.iconSizeExtraLarge*1.2

                    Image {
                        id: image
                        width: Theme.iconSizeExtraLarge
                        height: Theme.iconSizeExtraLarge
                        anchors.left: parent.left
                        anchors.leftMargin: Theme.horizontalPageMargin
                        anchors.verticalCenter: parent.verticalCenter
                        source: model.url
                        asynchronous: true
                        smooth: true
                        antialiasing: true
                        onStatusChanged:
                        {
                            if (status == Image.Loading)
                            {
                                progressIndicator.running = true
                            }
                            else
                            {
                                progressIndicator.running = false
                            }

                            if (status == Image.Error)
                            {
                                source = '../images/noImage.png'
                                progressIndicator.running = false
                            }
                        }

                        BusyIndicator {
                            id: progressIndicator
                            anchors.centerIn: parent
                            size: BusyIndicatorSize.Medium
                            running: true
                        }
                    }

                    Label {
                        id: name
                        anchors.left: image.right;
                        anchors.leftMargin: Theme.horizontalPageMargin;
                        anchors.verticalCenter: parent.verticalCenter
                        wrapMode: Text.WordWrap
                        maximumLineCount: 1
                        font.pixelSize: Theme.fontSizeExtraLarge
                        text: model.name
                    }

                    Image {
                        anchors.left: name.right
                        anchors.leftMargin: Theme.horizontalPageMargin
                        anchors.verticalCenter: parent.verticalCenter
                        source: "image://theme/icon-m-favorite-selected"
                        visible: model.super_like
                    }

                    onClicked:
                    {
                        matchesModel.setProperty(index, "new_messages", false) // Unhighlight this person since we read the message
                        pageStack.push(Qt.resolvedUrl('MessagingPage.qml'), {personID: model.ID, bio: model.bio, photos: model.photos, gender: model.gender, age: model.age, messages: model.messages, image: model.url, last_active: model.last_active, name: model.name, matchID: matchID});
                    }

                    menu: ContextMenu {

                        MenuItem {
                            text: "About"
                            onClicked:
                            {
                                pageStack.push(Qt.resolvedUrl('AboutPage.qml'), {personID: model.ID, bio: model.bio, photos: model.photos, last_active: model.last_active, name: model.name, gender: model.gender, age: model.age});
                            }
                        }

                        MenuItem {
                            text: "Report for SPAM"
                            onClicked:
                            {
                                remorse.execute("Reporting", function()
                                {
                                    python.call('api.report',[model.ID, 1], function(personID, causeID) {});
                                })
                            }
                        }

                        MenuItem {
                            text: "Report for inappropriate"
                            onClicked:
                            {
                                remorse.execute("Reporting", function()
                                {
                                    python.call('api.report',[model.ID, 2], function(personID, causeID) {});
                                })
                            }
                        }

                        MenuItem {
                            text: "Unmatch"
                            onClicked:
                            {
                                remorse.execute("Unmatching", function()
                                {
                                    python.call('api.unmatch',[model.matchID], function(matchID) {});
                                    message.text = qsTr("Refreshing...")
                                    message.hintText = qsTr("A moment please")
                                    message.enabled = true
                                    matchesModel.clear()
                                    python.call('api.last_activity',[''], function(empty) {});
                                })
                            }
                        }
                    }
                }
            }
            VerticalScrollDecorator {}
        }

        // Create a list of all matches. We will fill this list later with Python.
        ListModel {
            id: matchesModel
        }

        ViewPlaceholder {
            id: message
            enabled: true
            text: qsTr("Loading matches...")
            hintText: qsTr("A moment please")
        }

        Timer {
            id: refresh
            interval: 15*60*1000
            running: false
            repeat: true
            onTriggered:
            {
                matchesModel.clear()
                python.call('api.people',[], function() {});
            }
        }

        Python {
            id: python
            Component.onCompleted:
            {
                // Add the Python path to PyOtherSide and import our module 'api'.
                addImportPath(Qt.resolvedUrl('.'));
                importModule('api', function() {});

                // Ask when we were last online as soon as Python is ready for it
                python.call('api.last_activity',[''], function(empty) {});

                setHandler('last_active', function(date) // Reduces the calls of last_active to one (previously every match)
                {
                    last_active = date

                    // Ask for our people now
                    python.call('api.people',[], function() {});
                });

                setHandler('matches', function(matchData)
                {
                    //console.log(JSON.stringify(matchData))
                    loadMatches(matchData)
                    message.enabled = false
                    refresh.restart()
                });
            }

            onError:
            {
                console.log('Python ERROR: ' + traceback);
                Clipboard.text = traceback
                pageStack.completeAnimation();
                pageStack.replace(Qt.resolvedUrl('ErrorPage.qml'));
            }

            //DEBUG
            /*onReceived:
        {
            console.log('Python MESSAGE: ' + data);
        }*/
        }
    }
}
