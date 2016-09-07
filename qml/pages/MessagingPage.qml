import QtQuick 2.2
import QtQuick.Window 2.0;
import Sailfish.Silica 1.0
import io.thp.pyotherside 1.3
import "../pages/lib/helper.js" as Helper

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

    Component.onCompleted:
    {
        last_active = Helper.caculate_last_seen(last_active)
        lastSeen.text = qsTr("Last seen: ") + last_active
        nameLabel.text = name
    }

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

            Column {
                id: layout
                anchors
                {
                    left: (item.alignRight ? parent.left : undefined)
                    right: (!item.alignRight ? parent.right : undefined)
                    margins: -shadow.anchors.margins
                    verticalCenter: parent.verticalCenter
                }

                Text {
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
                }

                Label {
                    id: timestamp
                    anchors.right: parent.right
                    font.pixelSize: Theme.fontSizeTiny
                    text: Helper.caculate_last_seen(model.sent_date)
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

        TextArea {
            id: messages_box
            width: parent.width - send_message.width
            placeholderText: qsTr("Hi ") + name + qsTr("!")
        }

        IconButton {
            id: send_message
            icon.source: "image://theme/icon-m-message"
            onClicked: {
                messages.append({from: 'myself', message: messages_box.text});
                messages_box.label = qsTr("Message send!");
                view.positionViewAtEnd()
                python.call('api.send_message',[messages_box.text, matchID], function(message, matchID) {});
                reset_message_bar.start();
            }
        }
    }

    SilicaFlickable {
        ViewPlaceholder {
            id: message
            enabled: !Qt.inputMethod.visible && !messages.count
            text: qsTr("No messages :(")
            hintText: qsTr("Say hi to ") + name + qsTr("!")
        }
    }

    Timer {
        id: reset_message_bar
        interval: 100
        running: false
        repeat: true
        onTriggered:
        {
            counter_reset_timer++
            messages_box.text = "";
            messages_box.focus = false;
            if(counter_reset_timer > 10)
            {
                messages_box.placeholderText = qsTr("Hi ") + name + qsTr("!")
                counter_reset_timer = 0
            }
        }
    }

    Connections {
        target: Qt.inputMethod
    }

    Python {
        id: python
        Component.onCompleted:
        {
            // Add the Python path to PyOtherSide and import our module 'api'.
            addImportPath(Qt.resolvedUrl('.'));
            importModule('api', function() {});
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
        /*onReceived:
        {
            console.log('Python MESSAGE: ' + data);
        }*/
    }
}


