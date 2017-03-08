import QtQuick 2.2
import QtQuick.Window 2.0;
import Sailfish.Silica 1.0
import io.thp.pyotherside 1.3
import "../pages/js/helper.js" as Helper

Page {
    id: page

    property int counter_reset_timer

    // Sailfinder API
    property string personID
    property string matchID
    property var messages
    property var image
    property var last_active
    property string name
    property var age
    property int gender
    property var photos
    property string bio
    property var gifs

    function loadGIFs(gifs)
    {
        for (var i = 0; i < Object.keys(gifs['data']).length; i++)
        {
            //gifsModel.append({url: gifs['data'][i]['embed_url'], id: gifs['data'][i]['id']})
            gifsModel.append({url: gifs['data'][i]['images']['original']['url'], id: gifs['data'][i]['id']})
        }
    }

    Component.onCompleted:
    {
        last_active = Helper.calculate_last_seen(last_active)
        lastSeen.text = qsTr("Last seen: ") + last_active
        nameLabel.text = name
    }

    NetworkStatus {}

    Item {
        id: header
        height: Theme.itemSizeExtraLarge
        anchors
        {
            top: parent.top
            left: parent.left
            right: parent.right
        }

        Rectangle {
            anchors.fill: parent
            z: -1
            color: "black"
            opacity: 0.15
        }

        Image {
            id: avatar
            width: Theme.iconSizeLarge
            height: width
            anchors
            {
                right: parent.right
                margins: Theme.paddingLarge
                verticalCenter: parent.verticalCenter
            }
            asynchronous: true
            smooth: true
            antialiasing: true
            source: image
            fillMode: Image.PreserveAspectCrop

            onStatusChanged:
            {
                if (status == Image.Loading)
                {
                    progressIndicator.running = true
                }
                else if (status == Image.Error)
                {
                    source = '../images/noImage.png'
                    progressIndicator.running = false
                }
                else
                {
                    progressIndicator.running = false
                }
            }

            BusyIndicator {
                id: progressIndicator
                anchors.centerIn: parent
                size: BusyIndicatorSize.Medium
                running: true
            }

            Rectangle {
                anchors.fill: parent
                z: -1
                color: "black"
                opacity: 0.35
            }

            MouseArea {
                anchors.fill: parent
                onClicked:
                {
                    pageStack.push(Qt.resolvedUrl('AboutPage.qml'), {personID: personID, bio: bio, photos: photos, last_active: last_active, name: name, gender: gender, age: age});
                }
            }
        }

        Column {
            anchors {
                right: avatar.left
                margins: Theme.paddingLarge
                verticalCenter: parent.verticalCenter
            }

            Label {
                id: nameLabel
                anchors.right: parent.right
                color: Theme.highlightColor
                font {
                    family: Theme.fontFamilyHeading
                    pixelSize: Theme.fontSizeLarge
                }
                text: qsTr("N/A")
            }

            Label {
                id: lastSeen
                anchors.right: parent.right
                color: Theme.secondaryColor
                font {
                    family: Theme.fontFamilyHeading
                    pixelSize: Theme.fontSizeTiny
                }
                text: qsTr("last seen: N/A")
            }
        }
    }

    SilicaListView {
        id: view
        anchors
        {
            top: header.bottom
            left: parent.left
            right: parent.right
            bottom: message_bar.top
        }
        Component.onCompleted: positionViewAtEnd()
        clip: true
        model: messages
        header: Item {
            height: view.spacing
            anchors
            {
                left: parent.left
                right: parent.right
            }
        }
        footer: Item {
            height: view.spacing
            anchors
            {
                left: parent.left
                right: parent.right
            }
        }
        spacing: Theme.paddingMedium
        delegate: Item {
            id: item
            height: shadow.height
            anchors
            {
                left: parent.left
                right: parent.right
                margins: view.spacing
            }

            readonly property bool alignRight:
            {
                if(model.from == personID) // Same aliging as in the Jolla Messaging app
                {
                    false
                }
                else
                {
                    true
                }
            }
            readonly property int  maxContentWidth : (page.width * 0.85);

            Rectangle {
                id: shadow
                anchors
                {
                    fill: layout
                    margins: -Theme.paddingSmall
                }
                color: "white"
                radius: 3
                opacity: (item.alignRight ? 0.05 : 0.15)
                antialiasing: true
            }

            //readonly property string iconlocation: like_message.icon.source

            /*IconButton { // NEEDS API FIXING
                id: like_message
                anchors.left: layout.right
                anchors.leftMargin: Theme.paddingMedium
                anchors.verticalCenter: layout.verticalCenter
                icon.source: "../images/message_dislike.png"
                visible: item.alignRight
                opacity: 0.5
                onClicked:
                {
                    if(iconlocation.match("dislike.png"))
                    {
                        icon.source = "../images/message_like.png"
                        opacity = 1.0
                        python.call('api.like_message',[true, model._id], function(like, message_id) {});
                        console.log("[INFO] Message " + model._id + " liked")
                    }
                    else if(iconlocation.match("like.png"))
                    {
                        icon.source = "../images/message_dislike.png"
                        opacity = 0.5
                        python.call('api.like_message',[false, model._id], function(like, message_id) {});
                        console.log("[INFO] Message: " + model._id + " disliked")
                    }
                }
                Behavior on opacity {
                    FadeAnimation {}
                }
            }*/

            Column {
                id: layout
                anchors
                {
                    left: (item.alignRight ? parent.left : undefined)
                    right: (!item.alignRight ? parent.right : undefined)
                    margins: -shadow.anchors.margins
                    verticalCenter: parent.verticalCenter
                }
                spacing: Theme.paddingSmall

                Text {
                    id: message_text
                    width: Math.min(page.width*0.8, contentWidth)
                    anchors
                    {
                        left: (item.alignRight ? parent.left : undefined)
                        right: (!item.alignRight ? parent.right : undefined)
                    }
                    color: Theme.primaryColor
                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                    font
                    {
                        family: Theme.fontFamilyHeading
                        pixelSize: Theme.fontSizeMedium
                    }
                    text: model.message
                    visible: !text.match('.giphy.com/media/')
                }

                AnimatedImage {
                    id: gif
                    width: Theme.itemSizeExtraLarge*3
                    height: width
                    visible: !message_text.visible
                    fillMode: visible? Image.PreserveAspectFit: Image.Pad
                    source: if(visible)
                            {
                                model.message
                            }
                            else
                            {
                                '../images/no_gif.gif'
                            }
                    onStatusChanged:
                    {
                        if (status == AnimatedImage.Loading)
                        {
                            progressIndicator.running = true
                        }
                        else if (status == AnimatedImage.Error)
                        {
                            source = '../images/noImage.png'
                            progressIndicator.running = false
                        }
                        else
                        {
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
                    id: timestamp
                    anchors.right: parent.right
                    font.pixelSize: Theme.fontSizeTiny
                    text: Helper.calculate_last_seen(model.sent_date)
                }
            }
        }
    }

    Item {
        id: gif_gallery
        width: parent.width
        height: Theme.itemSizeHuge*1.5
        anchors.bottom: message_bar.top
        opacity: 0

        Behavior on opacity {
            FadeAnimation {}
        }

        Rectangle {
            anchors.fill: parent
            width: parent.width
            height: parent.height
            color: Theme.secondaryHighlightColor
        }

        SlideshowView {
            width: parent.width
            height: parent.height
            anchors.fill: parent
            itemWidth: width
            model: gifsModel

            delegate: AnimatedImage {
                width: parent.width/1.2
                height: parent.height
                source: model.url
                asynchronous: true
                smooth: true
                antialiasing: true
                onStatusChanged:
                {
                    if (status == Image.Loading)
                    {
                        progressIndicator1.running = true
                    }
                    else if (status == Image.Error)
                    {
                        source = '../images/noImage.png'
                        progressIndicator1.running = false
                    }
                    else
                    {
                        progressIndicator1.running = false
                    }
                }

                BusyIndicator {
                    id: progressIndicator1
                    anchors.centerIn: parent
                    size: BusyIndicatorSize.Medium
                    running: true
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked:
                    {
                        // Send GIF
                        python.call('api.send_message',[model.url, matchID, true, model.id], function(message, matchID, gif, gif_id) {});
                        messages.append({from: 'myself', message: model.url});

                        // Clear
                        gif_gallery.opacity = 0;
                        messages_box.placeholderText = qsTr("Hi ") + name + qsTr("!");
                        send_message.icon.source = "image://theme/icon-m-message";
                        view.positionViewAtEnd()
                    }
                }
            }
        }
    }

    Row {
        id: message_bar
        anchors
        {
            left: parent.left
            right: parent.right
            bottom: parent.bottom
        }

        BackgroundItem {
            id: show_gifs
            width: Theme.iconSizeLarge
            height: Theme.iconSizeLarge
            onClicked:
            {
                gif_gallery.opacity = !gif_gallery.opacity
                messages_box.text = ""; // Clear the message otherwise the message will be used as search term in GIPHY
                if(gif_gallery.opacity == 0)
                {
                    python.call('api.get_gifs',[], function(search_word) {});
                    messages_box.placeholderText = qsTr("Search for GIFs")
                    send_message.icon.source = "image://theme/icon-m-search"
                }
                else
                {
                    messages_box.placeholderText = qsTr("Hi ") + name + qsTr("!")
                    send_message.icon.source = "image://theme/icon-m-message"
                }
            }

            Label {
                anchors.centerIn: parent
                text: qsTr("GIF")
            }
        }

        TextArea {
            id: messages_box
            width: parent.width - send_message.width - show_gifs.width
            placeholderText: qsTr("Hi ") + name + qsTr("!")
        }

        IconButton {
            id: send_message
            icon.source: "image://theme/icon-m-message"
            onClicked: {
                if(icon.source == "image://theme/icon-m-message")
                {
                    messages.append({from: 'myself', message: messages_box.text});
                    messages_box.label = qsTr("Message send!");
                    view.positionViewAtEnd()
                    python.call('api.send_message',[messages_box.text, matchID, false, ''], function(message, matchID, gif, gif_id) {});
                    reset_input.start();
                }
                else
                {
                    view.positionViewAtEnd()
                    gifsModel.clear(); // Make place for new GIFS
                    python.call('api.get_gifs',[messages_box.text], function(search_word) {});
                }
            }
        }
    }

    SilicaFlickable {
        ViewPlaceholder {
            id: screen_message
            enabled: !Qt.inputMethod.visible && !messages.count
            text: qsTr("No messages :(")
            hintText: qsTr("Say hi to ") + name + qsTr("!")
        }
    }

    Connections {
        target: Qt.inputMethod
    }

    Timer {
        id: reset_input
        interval: 100
        running: false
        repeat: true
        onTriggered:
        {
            counter_reset_timer++
            if(counter_reset_timer < 2)
            {
                messages_box.text = "";
                messages_box.focus = false;
            }

            if(counter_reset_timer > 10)
            {
                messages_box.placeholderText = qsTr("Hi ") + name + qsTr("!")
                counter_reset_timer = 0
                reset_input.stop()
            }
        }
    }

    ListModel {
        id: gifsModel
    }

    Python {
        id: python

        Component.onCompleted:
        {
            setHandler('gifs', function(gifs_data) // Reduces the calls of last_active to one (previously every match)
            {
                //console.log(JSON.stringify(gifs_data))
                loadGIFs(gifs_data[1]);
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
        onReceived:
        {
            console.log('Python MESSAGE: ' + data);
        }
    }
}


