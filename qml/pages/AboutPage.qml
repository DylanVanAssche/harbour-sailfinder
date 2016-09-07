import QtQuick 2.2
import Sailfish.Silica 1.0
import io.thp.pyotherside 1.3

Page {
    id: page

    property var photo_url

    // Sailfinder API
    property var personID
    property var gender
    property var name
    property var distance_mi
    property var distance_km
    property var bio
    property var photos
    property var age

    Component.onCompleted:
    {
        load_user()
    }

    function load_user()
    {
        if(gender)
        {
            //header.title = name + ' (' + age + ') ♀ - ' + distance_km + ' km' // Need API user
            header.title = name + ' (' + age + ') ♀'
        }
        else
        {
            //header.title = name + ' (' + age + ') ♂ - ' + distance_km + ' km' // Need API user
            header.title = name + ' (' + age + ') ♂'
        }
    }

    SilicaFlickable {
        anchors.fill: parent
        contentHeight: column.height

        Column {
            id: column
            width: page.width
            spacing: Theme.paddingLarge

            PageHeader {
                id: header
                title: qsTr("N/A")
            }

            Item {
                width: parent.width
                height: (width*2)/3

            SilicaGridView {
                id: gallery
                width: parent.width
                height: (width*2)/3
                cellWidth: parent.width/3
                cellHeight: cellWidth
                anchors.fill: parent
                model: photos
                opacity: 1.0
                delegate: Item {
                    width: gallery.cellWidth
                    height: gallery.cellHeight

                    Image {
                        id: image
                        width: gallery.cellWidth/1.05
                        height: gallery.cellHeight/1.05
                        anchors.centerIn: parent
                        source: model.url
                        fillMode: Image.PreserveAspectCrop
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
                        }

                        BusyIndicator {
                            id: progressIndicator
                            anchors.centerIn: parent
                            size: BusyIndicatorSize.Small
                            running: true
                        }
                    }
                }
            }
            }

            Label {
                id: bioPerson
                anchors {
                    left: parent.left
                    right: parent.right
                    leftMargin: Theme.horizontalPageMargin
                    rightMargin: Theme.horizontalPageMargin
                }
                font.pixelSize: Theme.fontSizeSmall
                wrapMode: Text.WordWrap
                text: bio
            }
        }
    }

    Python {
        id: python
        Component.onCompleted:
        {
            // Add the Python path to PyOtherSide and import our module 'api'.
            addImportPath(Qt.resolvedUrl('.'));
            importModule('api', function() {});

            // Ask for the user data as soon as Python is ready
            //python.call('api.user',[personID], function(person_id) {});

            setHandler('user', function(user_data)
            {
                //load_user(user_data)
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
