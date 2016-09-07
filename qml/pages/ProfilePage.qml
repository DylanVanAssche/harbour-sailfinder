import QtQuick 2.2
import Sailfish.Silica 1.0
import io.thp.pyotherside 1.3
import "../pages/lib/helper.js" as Helper

Page {

    // Sailfinder API data
    property var profile: ''
    property var name: ''
    property var full_name: ''
    property var username: ''
    property int gender_filter: 0
    property var interested_in: 0
    property var interests: ''
    property var photos: ''
    property int photos_count: 0
    property int gender: 0
    property string birth_date: ''
    property int age: 18
    property int distance_mi: 0
    property int distance_km: 0
    property var friends_tinder_social: ''
    property var current_position: ''
    property var standard_position: ''
    property var high_school: ''
    property var college: ''
    property int age_filter_max: 0
    property int age_filter_min: 0
    property int distance_filter_max: 0
    property int distance_filter_min: 0
    property bool discoverable: false
    property string last_active: ''
    property var groups: ''
    property string latest_update_date: ''
    property var schools: ''
    property string bio: ''
    property var jobs: ''
    property string ping_time: ''
    property string connection_count: ''
    property var common_friends: ''
    property var common_friends_count: ''
    property var common_likes: ''
    property var common_like_count: ''
    property string teaser: ''
    property var badges: ''
    property bool superLikeLimit: false
    property string superLikeResetsIn: ''
    property bool matched: false

    function load_profile()
    {
        name = profile['name']
        full_name = profile['full_name']
        bio = profile['bio']
        photos = profile['photos']
        gender = profile['gender']
        gender_filter = profile['gender_filter']
        interested_in = profile['interested_in']
        interests = profile['interests']
        friends_tinder_social = profile['friends']
        birth_date = profile['birth_date']
        username = profile['username']
        ping_time = profile['ping_time']
        current_position = profile['pos']
        standard_position = profile['pos_major']
        schools = profile['schools']
        high_school = profile['high_school']
        college = profile["college"] //FB ID COLLEGE
        jobs = profile['jobs']
        badges = profile['badges']
        age_filter_max = profile['age_filter_max']
        age_filter_min = profile['age_filter_min']
        discoverable = profile['discoverable']
        distance_filter_max = profile['distance_filter']
        distance_filter_min = profile['distance_filter_min']
        last_active = profile['active_time']
        groups = profile['groups']
        latest_update_date = profile['latest_update_date']

        age = Helper.calculate_age(birth_date);
        set_header()
        load_photos()

        // Update cover
        cover_data.text = name + qsTr("'s profile")
        cover_data.image = photos[0]['url']
        cover_data.text_enabled = true
        cover_data.image_enabled = true
        cover_data.actions_enabled = false

        //console.log(JSON.stringify(profile['photos'][0]["url"]))
    }

    function load_photos()
    {
        photosProfile.clear(); // Clear the photos when we update
        for (var i = 0; i < Object.keys(photos).length; i++)
        {
            photosProfile.append({url: photos[i]['url']});
        }
    }

    function set_header()
    {
        if(gender)
        {
            header.title = name + ' (' + age + ') ♀ - ' + qsTr("Profile")
        }
        else
        {
            header.title = name + ' (' + age + ') ♂ - ' + qsTr("Profile")
        }
    }

    SilicaFlickable {
        anchors.fill: parent
        contentHeight: pageColumn.height

        Column {
            id: pageColumn
            width: parent.width
            spacing: Theme.paddingLarge

            PageHeader {
                id: header
                title: qsTr("Profile")
            }

            PullDownMenu {
                MenuItem {
                    text: qsTr("Update profile")
                    onClicked:
                    {
                        // Open the UpdateProfile page.
                        pageStack.replace(Qt.resolvedUrl('UpdateProfilePage.qml'));
                    }
                }
            }

            SlideshowView {
                width: parent.width
                height: width
                itemWidth: width
                model: photosProfile
                visible: !pageStack.busy

                delegate: Image {
                    width: parent.width / 1.05
                    height: width
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
                }
            }

            Label {
                text: bio
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
            Item {
                height: 20
                width: parent.width
            }
        }
    }

    ListModel {
        id: photosProfile
    }

    Python {
        id: python
        Component.onCompleted:
        {
            // Add the Python path to PyOtherSide and import our module 'api'.
            addImportPath(Qt.resolvedUrl('.'));
            importModule('api', function() {});

            // When Python is ready, load our Tinder profile...
            python.call('api.profile',[], function() {});

            // Get the profile data.
            setHandler('profile', function(profile_data)
            {
                //console.log(JSON.stringify(profile))
                profile = profile_data
                load_profile()
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
