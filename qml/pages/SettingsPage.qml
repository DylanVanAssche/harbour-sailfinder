import QtQuick 2.2
import Sailfish.Silica 1.0
import io.thp.pyotherside 1.3
import QtPositioning 5.2

Dialog {
    id: page

    Component.onDestruction:
    {
        if(!page.reject) // Workaround Github issue #44 & #43
        {
            python.call('api.save_settings',[(bio.checked * bio.checked), (school.checked * school.checked), (job.checked * job.checked), (instagram.checked * instagram.checked)], function(bio, school, job, instagram) {});
        }
    }

    onStatusChanged:
    {
        if(status == PageStatus.Active)
        {
            cover_data.text = qsTr("Settings")
            cover_data.image = '../images/settings.png'
            cover_data.text_enabled = true
            cover_data.image_enabled = true
            cover_data.actions_enabled = false
        }
    }

    property string mapquest_key: '7jwW2xkWwiapD8K4rLkiKlSxOPqSKiLG'
    property var latitude: ''
    property var longitude: ''

    SilicaFlickable {
        anchors.fill: parent
        contentHeight: column.height

        Column {
            id: column
            width: page.width
            spacing: Theme.paddingLarge

            DialogHeader {
                title: qsTr("Settings")
            }

            RemorsePopup {
                id: remorse
            }

            SectionHeader { text: "Recommendations" }

            IconTextSwitch {
                id: bio
                icon.source: "../images/bio.png"
                text: qsTr("Show bio")
                checked: false
            }

            IconTextSwitch {
                id: school
                icon.source: "../images/school.png"
                text: qsTr("Show school")
                checked: false
            }

            IconTextSwitch {
                id: job
                icon.source: "../images/job.png"
                text: qsTr("Show job")
                checked: false
            }

            IconTextSwitch {
                id: instagram
                icon.source: "../images/instagram.png"
                text: qsTr("Show Instagram account")
                checked: false
            }

            SectionHeader { text: qsTr("Location") }

            Label {
                id: gps_lat
                anchors.left: parent.left
                anchors.leftMargin: Theme.horizontalPageMargin
                text: qsTr("Latitude: ") + latitude + '°'
                visible: location.position.latitudeValid && location.position.longitudeValid
            }

            Label {
                id: gps_lon
                anchors.left: parent.left
                anchors.leftMargin: Theme.horizontalPageMargin
                text: qsTr("Longitude: ") + longitude + '°'
                visible: location.position.latitudeValid && location.position.longitudeValid
            }

            Label {
                anchors.left: parent.left
                anchors.leftMargin: Theme.horizontalPageMargin
                text: qsTr("Waiting for GPS signal...")
                visible: !location.position.latitudeValid || !location.position.longitudeValid
            }

            Image {
                id: map
                width: parent.width
                height: width
                anchors
                {
                    left: parent.left
                    right: parent.right
                }
                asynchronous: true
                smooth: true
                antialiasing: true
                visible: location.position.latitudeValid && location.position.longitudeValid
                source: "https://open.mapquestapi.com/staticmap/v4/getmap?key=" + mapquest_key + "&center=" + location.position.coordinate.latitude + "," + location.position.coordinate.longitude + "&zoom=" + zoom_map.value +"&size=" + parent.width + "," + parent.width + "&type=map&imagetype=jpeg&pois=red_1-GPS," + location.position.coordinate.latitude + "," + location.position.coordinate.longitude
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
                    z: 1
                    width: parent.width
                    height: parent.height
                    anchors.fill: parent
                    color: "transparent"
                    border.color: Theme.secondaryHighlightColor
                    border.width: Theme.paddingLarge
                }
            }

            Slider {
                id: zoom_map
                width: parent.width
                value: 14
                minimumValue: 1
                maximumValue: 18
                stepSize: 1
                valueText: ((value/18)*100).toFixed(0)  + " %"
                label: qsTr("🔎 Zoom map")
            }

            SectionHeader { text: qsTr("Logout") }

            Button {
                anchors.horizontalCenter: parent.horizontalCenter
                text: qsTr("Logout Tinder")
                color: 'red'
                onClicked:
                {
                    remorse.execute("Logging out", function()
                    {
                        python.call('api.remove_tinder_token',[], function() {});
                        Qt.quit()
                    })
                }
            }

            SectionHeader { text: qsTr("About this app") }

            Button {
                anchors.horizontalCenter: parent.horizontalCenter
                text: qsTr("About")
                onClicked: pageStack.push(Qt.resolvedUrl('SailfinderPage.qml'));
            }

            // Spacer
            Item {
                height: 20
                width: parent.width
            }
        }
    }

    Timer {
        running: location.position.latitudeValid && location.position.longitudeValid
        repeat: true
        interval: 30*1000
        triggeredOnStart: true
        onTriggered:
        {
            latitude = location.position.coordinate.latitude
            longitude = location.position.coordinate.longitude
        }
    }

    Item {
        id: gps_data
        property alias positionSource: location
        PositionSource {
            id: location
            updateInterval: 5000
            active: true
            onPositionChanged:
            {
                console.log("[INFO] Position changed")
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

            // When Python is ready, ask for our settings
            python.call('api.get_settings',[], function() {});

            setHandler('settings', function(settings)
            {
                //console.log(JSON.stringify(settings))
                bio.checked = parseInt(settings['bio']);
                school.checked = parseInt(settings['school']);
                job.checked = parseInt(settings['job']);
                instagram.checked = parseInt(settings['instagram']);
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
            console.log('Python MESSAGE: ' + JSON.stringify(data));
        }*/
    }

    onAccepted:
    {
        //python.call('api.save_settings',[(bio.checked * bio.checked), (school.checked * school.checked), (job.checked * job.checked), (instagram.checked * instagram.checked)], function(bio, school, job, instagram) {});
    }
}

