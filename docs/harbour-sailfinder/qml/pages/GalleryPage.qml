import QtQuick 2.2
import Sailfish.Silica 1.0
import io.thp.pyotherside 1.3

Dialog {
    id: page
    canAccept: selected

    property var type
    property var name
    property var id
    property var url
    property var name_album
    property var photo_id_selected
    property bool selected: false

    function load_fb_albums(albums)
    {
        header.title = qsTr("Facebook albums")
        galleryAlbums.clear()
        galleryPhotos.clear()
        try {
            try {
                console.log("[ERROR] Facebook access token expired! " + albums['error']['message'])
                message.text = qsTr("Facebook login expired :-(")
                message.hintText = qsTr("Relogin into Facebook")
                message.enabled = true
                relogin.visible = true
            }
            catch(err)
            {
                for (var i = 0; i < Object.keys(albums['data']).length; i++)
                {
                    name = albums['data'][i]['name']
                    id = albums['data'][i]['id']
                    galleryAlbums.append({album: name, id: id})
                }
                message.enabled = false
                relogin.visible = false
            }
        }
        catch(err)
        {
            console.log("[ERROR] Facebook albums download failed: " + err)
            message.text = qsTr("Can't download albums :-(")
            message.hintText = qsTr("Check your Facebook permissions")
            message.enabled = true
        }
    }

    function load_fb_photos(photo)
    {
        header.title = ""
        try {
            id = photo['id']
            url = photo['source']
            galleryPhotos.append({id: id, url: url})
        }
        catch(err)
        {
            console.log("[ERROR] Facebook pictures download failed: " + err)
        }
    }

    NetworkStatus {}

    SilicaFlickable {
        anchors.fill: parent
        contentHeight: pageColumn.height

        Column {
            id: pageColumn
            width: parent.width
            spacing: Theme.paddingLarge

            DialogHeader {
                id: header
                title: qsTr("Gallery")
                acceptText: qsTr("Upload")
            }

            SilicaListView {
                id: album_list
                width: parent.width
                height: galleryAlbums.count*Theme.iconSizeExtraLarge*1.2
                anchors.left: parent.left
                anchors.right: parent.right
                model: galleryAlbums
                quickScroll: true
                clip: true
                visible: !photos_grid.visible
                delegate: ListItem {
                    contentHeight: Theme.iconSizeExtraLarge*1.2

                    Image {
                        id: image
                        width: Theme.iconSizeExtraLarge
                        height: Theme.iconSizeExtraLarge
                        anchors.left: parent.left
                        anchors.leftMargin: Theme.horizontalPageMargin
                        anchors.verticalCenter: parent.verticalCenter
                        source: '../images/noImage.png'
                        asynchronous: true
                        smooth: true
                        antialiasing: true
                        onStatusChanged:
                        {
                            if (status == Image.Loading)
                            {
                                progressIndicator1.running = true
                            }
                            else
                            {
                                progressIndicator1.running = false
                            }

                            if (status == Image.Error)
                            {
                                source = '../images/noImage.png'
                                progressIndicator1.running = false
                            }
                        }

                        BusyIndicator {
                            id: progressIndicator1
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
                        text: model.album
                    }

                    onClicked:
                    {
                        python.call('api.get_fb_pictures',[model.id], function(fb_album_id) {});
                        photos_grid.visible = true
                        name_album = model.album
                        galleryPhotos.append({id: 'back', url: "image://theme/icon-m-back"})
                    }
                }
                VerticalScrollDecorator {}
            }


            SilicaGridView {
                id: photos_grid
                width: parent.width
                height: Screen.height
                cellWidth: parent.width/3
                cellHeight: cellWidth
                model: galleryPhotos
                visible: false
                delegate: BackgroundItem {
                    width: photos_grid.cellWidth
                    height: photos_grid.cellHeight
                    onClicked:
                    {
                        if(model.id.length > 10)
                        {
                            if(photo_id_selected == model.id || !selected)
                            {
                                selectedPhoto.visible = !selectedPhoto.visible;
                                if(selectedPhoto.visible)
                                {
                                    photo_id_selected = model.id;
                                    selected = true;
                                }
                                else
                                {
                                    photo_id_selected = '';
                                    selected = false;
                                }
                            }
                        }
                        else
                        {
                            photos_grid.visible = false
                            galleryPhotos.clear()
                        }
                    }

                    Rectangle {
                        id: selectedPhoto
                        anchors.fill: parent
                        color: Theme.secondaryHighlightColor
                        opacity: 0.7
                        visible: false
                    }

                    Image {
                        width: photos_grid.cellWidth/1.1
                        height: width
                        anchors.centerIn: parent
                        source: model.url
                        asynchronous: true
                        onStatusChanged:
                        {
                            if (status == Image.Loading)
                            {
                                progressIndicator2.running = true
                            }
                            else if (status == Image.Error)
                            {
                                source = '../images/noImage.png'
                                progressIndicator2.running = false
                            }
                            else
                            {
                                progressIndicator2.running = false
                            }
                        }

                        BusyIndicator {
                            id: progressIndicator2
                            anchors.centerIn: parent
                            size: BusyIndicatorSize.Small
                            running: true
                        }
                    }
                }
            }
        }

        Button {
            id: relogin
            anchors.top: message.bottom
            anchors.topMargin: Theme.paddingLarge
            anchors.horizontalCenter: parent.horizontalCenter
            text: qsTr("Relogin with Facebook")
            onClicked:
            {
                python.call('api.remove_tinder_token',[], function() {});
                message.text= qsTr("Restart Sailfinder now")
                message.hintText= qsTr("Shutdown in 5 seconds")
                relogin.visible = false
                quit.start()
            }
        }

        ListModel {
            id: galleryAlbums
        }

        ListModel {
            id: galleryPhotos
        }

        ViewPlaceholder
        {
            id: message
            enabled: false
        }

        Timer {
            id: quit
            running: false
            repeat: false
            interval: 5000
            onTriggered: Qt.quit()
        }

        Python {
            id: python
            Component.onCompleted:
            {
                // When Python is ready, load our profile...
                if(type == 'fb')
                {
                    python.call('api.get_fb_albums',[], function() {});
                }

                setHandler('fb_albums', function(fb_albums)
                {
                    console.log(JSON.stringify(fb_albums))
                    load_fb_albums(fb_albums);
                });

                setHandler('fb_photos', function(fb_photos)
                {
                    console.log(JSON.stringify(fb_photos))
                    load_fb_photos(fb_photos);
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
            /*onReceived:
            {
                console.log('Python MESSAGE: ' + data);
            }*/
        }
    }

    onAccepted:
    {
        python.call('api.upload_fb_picture',[photo_id_selected], function(photo_id_selected) {});
    }
}
