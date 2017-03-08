import QtQuick 2.2
import Sailfish.Silica 1.0
import io.thp.pyotherside 1.3
import QtPositioning 5.2
import "../pages/js/helper.js" as Helper

Page {

    id: mainPage

    onStatusChanged:
    {
        if(status == PageStatus.Active)
        {
            if(!banned)
            {
                if(name != 'Tinder Team')
                {
                    try {
                        cover_data.text = name + ' (' + age + ')'
                        cover_data.image = photos[0]['url']
                        cover_data.actions_enabled = true
                    }
                    catch(err)
                    {
                        console.log("[ERROR] Can't load cover for recommendations: " + err)
                        cover_data.text = qsTr("No data")
                        cover_data.image = '../images/harbour-sailfinder.png'
                        cover_data.actions_enabled = false
                    }

                    cover_data.text_enabled = true
                    cover_data.image_enabled = true
                }
                else
                {
                    cover_data.text = qsTr("Out of likes!")
                    cover_data.image = '../images/harbour-sailfinder.png'
                    cover_data.text_enabled = true
                    cover_data.image_enabled = true
                    cover_data.actions_enabled = false
                }

                if(app.search_preferences_updated)
                {
                    search_preferences_updated = false;
                    message.text = qsTr("Searching for people")
                    message.hintText = qsTr("A moment please...")
                    message.enabled = true
                    cover_data.text = qsTr("Searching...")
                    cover_data.image = '../images/harbour-sailfinder.png'
                    cover_data.text_enabled = true
                    cover_data.image_enabled = false
                    cover_data.actions_enabled = false
                    header.title = qsTr("Loading new people...")
                    python.call('api.recommendations',[], function() {});
                    person = 0;
                }
            }
        }
    }

    Component.onDestruction:
    {
        var date = new Date();
        python.call('api.last_activity',[date.toISOString()], function(last_activity_ISO_format) {});
    }

    property bool buttonsEnabled: true
    property int person
    property string rateLimitID: 'tinder_rate_limited'
    property string school
    property string job
    property string instagram_username
    property bool bio_enabled
    property bool school_enabled
    property bool job_enabled
    property bool instagram_enabled
    property int photosInstagramCount
    property bool banned

    // Sailfinder API data
    property var people
    property var type
    property var content_hash
    property string personID
    property string photoID
    property string name
    property var photos
    property int gender
    property string birth_date
    property string birth_date_info
    property int age
    property int distance_mi
    property int distance_km
    property var schools
    property string bio
    property var jobs
    property string ping_time
    property string connection_count
    property var common_friends
    property var common_friends_count
    property var common_likes
    property var common_like_count
    property string teaser
    property string badges
    property var superLikeLimit
    property string superLikeResetsIn
    property bool matched
    property string matched_name
    property string matched_photo
    property var instagram_data

    function nextPerson()
    {
        person++;

        python.call('api.superlike_available',[], function() {}); // Check if superlikes are now available...
        python.call('api.get_settings',[], function() {}); // Settings changed?
        //console.log("[DEBUG] Number of recommendations: " + Object.keys(people).length)

        if(person >= Object.keys(people).length) // Our recommendation limit is 10 people, so after the 10th person we need to reload our recommendations.
        {
            message.text = qsTr("Searching for people")
            message.hintText = qsTr("A moment please...")
            message.enabled = true
            cover_data.text = qsTr("Searching...")
            cover_data.image = '../images/harbour-sailfinder.png'
            cover_data.text_enabled = true
            cover_data.image_enabled = false
            cover_data.actions_enabled = false
            header.title = qsTr("Loading new people...")
            python.call('api.recommendations',[], function() {});
            person = 0;
        }
        else
        {
            loadPerson();
        }
    }

    function loadPerson()
    {
        try {
            personID = people[person]['_id']
            app.personIDParent = personID
            //console.log(JSON.stringify(people[person]))

            if(personID.indexOf(rateLimitID) < 0) // Check if we have likes remaining or not?
            {
                try
                {
                    content_hash = people[person]['content_hash'] // Some weird token from Tinder which is passed to Tinder back when running an action on the user in the V2 API
                    console.log('[INFO] Content hash: ' + content_hash)
                }
                catch(err)
                {
                    console.log('[ERROR] Unable to fetch <content_hash> from user: ' + err)
                }

                name = people[person]['name']
                photos = people[person]['photos']
                gender = people[person]['gender']
                birth_date = people[person]['birth_date']
                birth_date_info = people[person]['birth_date_info']
                distance_mi = people[person]['distance_mi']
                distance_km = distance_mi * 1.609344
                schools = people[person]['schools']
                bio = people[person]['bio']
                jobs = people[person]['jobs']
                ping_time = people[person]['ping_time']
                instagram_data = people[person]['instagram']
                //connection_count = people[person]['connection_count']
                //common_friends = people['common_friends']
                //common_friends_count = people['common_friends_count']
                //common_likes = people['common_likes'] //Error: Cannot assign QVariantMap to QString
                //common_like_count = people['common_like_count']

                age = Helper.calculate_age(birth_date);

                load_photos();
                set_header(false)
                school = ''
                job = ''
                instagram_username = ''

                try {
                    for (var i = 0; i < Object.keys(schools).length; i++)
                    {
                        if(i > 0)
                        {
                            school += ', ' + schools[i]['name']
                        }
                        else
                        {
                            school = schools[i]['name']
                        }
                    }
                }
                catch(err)
                {
                    console.log("[INFO] No schools for: " + name)
                }

                for (var i = 0; i < Object.keys(jobs).length; i++)
                {
                    try {
                        if(i > 0)
                        {
                            job += ', ' + jobs[i]['company']['name'] + ': ' + jobs[i]['title']['name']
                        }
                        else
                        {
                            job = jobs[i]['company']['name'] + ': ' + jobs[i]['title']['name']
                        }
                    }
                    catch(err)
                    {
                        try {
                            if(i > 0)
                            {
                                job += ', ' + jobs[i]['company']['name']
                            }
                            else
                            {
                                job = jobs[i]['company']['name']
                            }
                        }
                        catch(err)
                        {
                            try {
                                if(i > 0)
                                {
                                    job += ', ' + jobs[i]['title']['name']
                                }
                                else
                                {
                                    job = jobs[i]['title']['name']
                                }
                            }
                            catch(err)
                            {
                                console.log("[INFO] No jobs for: " + name)
                            }
                        }
                    }
                }

                photosInstagram.clear(); // Clear the photos for the next person
                photosInstagramCount = 0;

                try {
                    instagram_username = instagram_data['username']
                    for (var i = 0; i < Object.keys(instagram_data['photos']).length; i++)
                    {
                        photosInstagram.append({thumbnail: instagram_data['photos'][i]['thumbnail'], url: instagram_data['photos'][i]['image']});
                    }
                }
                catch(err)
                {
                    console.log("[INFO] No instagram for user: " + name)
                }

                // Update cover
                cover_data.text = name + ' (' + age + ')'
                cover_data.image = photos[0]['url']
                cover_data.text_enabled = true
                cover_data.image_enabled = true
                cover_data.actions_enabled = true

                // Everything loaded, activate the buttons
                buttonsEnabled = true;
            }
            else // Out Of Likes
            {
                buttonsEnabled = false;
                bio = people[person]['bio']
                photos = people[person]['photos']
                name = people[person]['name']
                school = ''
                job = ''
                instagram_username = ''
                photosInstagram.clear()
                load_photos(photos)
                set_header(true)

                // Update cover
                cover_data.text = qsTr("Out of likes!")
                cover_data.image = '../images/harbour-sailfinder.png'
                cover_data.text_enabled = true
                cover_data.image_enabled = true
                cover_data.actions_enabled = false
            }
        }
        catch(err)
        {
            console.log("[DEBUG] API dump=" + JSON.stringify(people[person]))
            console.log("[ERROR] Failed to get person: " + err)
            message.text = qsTr("API ERROR")
            message.hintText = qsTr("Reloading in 5 seconds")
            message.enabled = true
            api_reload.start()
        }
    }

    function load_photos()
    {
        photosPeople.clear(); // Clear the photos for the next person
        for (var i = 0; i < Object.keys(photos).length; i++)
        {
            photosPeople.append({url: photos[i]['url'], ID: photos[i]['id']});
        }
    }

    function set_header(tinder_team)
    {
        if(tinder_team)
        {
            header.title = name
        }
        else
        {
            if(gender)
            {
                header.title = name + ' (' + age + ') ♀ - ' + distance_km + ' km'
            }
            else
            {
                header.title = name + ' (' + age + ') ♂ - ' + distance_km + ' km'
            }
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

            PageHeader {
                id: header
                title: app.name + ' ' + app.version
                visible: !matched_message.open && !app.network_error
            }

            PullDownMenu {
                id: pullDownMenu

                MenuItem {
                    text: qsTr("Settings")
                    onClicked:
                    {
                        // Open the Settings page and load the settings data.
                        pageStack.push(Qt.resolvedUrl('SettingsPage.qml'));
                    }
                    enabled: !app.network_error
                }

                MenuItem {
                    text: qsTr("Profile")
                    onClicked:
                    {
                        // Open the Profile page and load the profile data.
                        pageStack.push(Qt.resolvedUrl('ProfilePage.qml'));
                    }
                    enabled: !banned && !app.network_error
                }

                MenuItem {
                    text: qsTr("People")
                    onClicked:
                    {
                        // Open the People page and load the matches data + saved data.
                        pageStack.push(Qt.resolvedUrl('PeoplePage.qml'));
                    }
                    enabled: !banned && !app.network_error
                }
            }


            SlideshowView {
                id: gallery
                width: parent.width
                height: width
                itemWidth: width
                model: photosPeople
                visible: !pageStack.busy && !matched_message.open && !message.enabled && !banned
                enabled: !app.network_error
                opacity: !app.network_error? 1.0: 0.2 // Don't overshadow our network error message

                Behavior on opacity {
                    FadeAnimation {}
                }

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
                            progressIndicator1.running = true
                            photoID = model.ID // Asign new photo ID
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
                }
            }

            Item {
                width: parent.width
                height: buttonRow.height * 2
                visible: !matched_message.open && !message.enabled && !banned

                Row {
                    id: buttonRow
                    anchors.centerIn: parent
                    spacing: Theme.paddingLarge*3

                    IconButton {
                        icon.source: {
                            if (Screen.width < app.widthScreenLimit)
                            {
                                "../images/dislike_small.png"
                            }
                            else
                            {
                                "../images/dislike_large.png"
                            }
                        }
                        enabled: buttonsEnabled && !app.network_error
                        onClicked:
                        {
                            buttonsEnabled = false;
                            python.call('api.dislike',[personID], function(personID) {});
                        }
                    }

                    IconButton {
                        icon.source: {
                            if (Screen.width < app.widthScreenLimit)
                            {
                                "../images/superLike_small.png"
                            }
                            else
                            {
                                "../images/superLike_large.png"
                            }
                        }
                        enabled: buttonsEnabled && !superLikeLimit && !app.network_error
                        onClicked:
                        {
                            buttonsEnabled = false;
                            python.call('api.superlike',[personID], function(personID) {});
                        }
                    }

                    IconButton {
                        icon.source: {
                            if (Screen.width < app.widthScreenLimit)
                            {
                                "../images/like_small.png"
                            }
                            else
                            {
                                "../images/like_large.png"
                            }
                        }
                        enabled: buttonsEnabled && !app.network_error
                        onClicked:
                        {
                            buttonsEnabled = false;
                            python.call('api.like',[personID], function(personID) {});
                        }
                    }
                }
            }

            Label {
                id: bio_person
                anchors {
                    left: parent.left
                    right: parent.right
                    leftMargin: Theme.horizontalPageMargin
                    rightMargin: Theme.horizontalPageMargin
                }
                font.pixelSize: Theme.fontSizeSmall
                visible: !matched_message.open && !message.enabled && bio.length && bio_enabled && !banned
                wrapMode: Text.WordWrap
                text: bio
            }

            Item {
                id: school_person
                width: parent.width
                height: Theme.itemSizeLarge
                anchors {
                    left: parent.left
                    right: parent.right
                    leftMargin: Theme.horizontalPageMargin
                    rightMargin: Theme.horizontalPageMargin
                }
                visible: !matched_message.open && !message.enabled && school.length && school_enabled && !banned

                Image {
                    id: school_icon
                    width: Theme.iconSizeSmall
                    height: width
                    anchors.right: parent.right
                    anchors.top: parent.top
                    source: "../images/school_large.png"
                }

                Label {
                    id: school_label
                    anchors.right: school_icon.left
                    anchors.rightMargin: Theme.paddingMedium
                    anchors.top: parent.top
                    font.pixelSize: Theme.fontSizeSmall
                    text: qsTr("School")
                }

                Label {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.top: school_label.bottom
                    anchors.topMargin: Theme.paddingMedium
                    wrapMode: Text.WordWrap
                    font.pixelSize: Theme.fontSizeSmall
                    text: school
                }
            }

            Item {
                id: job_person
                width: parent.width
                height: Theme.itemSizeLarge
                anchors {
                    left: parent.left
                    right: parent.right
                    leftMargin: Theme.horizontalPageMargin
                    rightMargin: Theme.horizontalPageMargin
                }
                visible: !matched_message.open && !message.enabled && job.length && job_enabled && !banned

                Image {
                    id: job_icon
                    width: Theme.iconSizeSmall
                    height: width
                    anchors.right: parent.right
                    anchors.top: parent.top
                    source: "../images/job_large.png"
                }

                Label {
                    id: job_label
                    anchors.right: job_icon.left
                    anchors.rightMargin: Theme.paddingMedium
                    anchors.top: parent.top
                    font.pixelSize: Theme.fontSizeSmall
                    text: qsTr("Job")
                }

                Label {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.top: job_label.bottom
                    anchors.topMargin: Theme.paddingMedium
                    wrapMode: Text.WordWrap
                    font.pixelSize: Theme.fontSizeSmall
                    text: job
                }
            }

            Item {
                id: instagram_person
                width: parent.width
                height: Theme.itemSizeLarge + photos_grid.height
                anchors {
                    left: parent.left
                    right: parent.right
                    leftMargin: Theme.horizontalPageMargin
                    rightMargin: Theme.horizontalPageMargin
                }
                visible: !matched_message.open && !message.enabled && instagram_username.length && instagram_enabled && !banned

                BackgroundItem {
                    id: instagram_button
                    width: parent.width
                    height: Theme.itemSizeLarge
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.top: parent.top
                    onClicked:
                    {
                        Qt.openUrlExternally("https://www.instagram.com/" + instagram_username);
                    }

                    Image {
                        id: instagram_icon
                        width: Theme.iconSizeSmall
                        height: width
                        anchors.right: parent.right
                        anchors.top: parent.top
                        source: "../images/instagram_large.png"
                    }

                    Label {
                        id: instagram_icon_label
                        anchors.right: instagram_icon.left
                        anchors.rightMargin: Theme.paddingMedium
                        anchors.top: parent.top
                        font.pixelSize: Theme.fontSizeSmall
                        text: qsTr("Instagram")
                    }

                    Label {
                        id: instagram_username_label
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.top: instagram_icon_label.bottom
                        anchors.topMargin: Theme.paddingMedium
                        wrapMode: Text.WordWrap
                        font.pixelSize: Theme.fontSizeSmall
                        text: instagram_username
                    }
                }

                SilicaGridView {
                    id: photos_grid
                    width: parent.width
                    height: Math.ceil(photosInstagramCount/3) * cellHeight
                    cellWidth: parent.width/3
                    cellHeight: cellWidth
                    anchors.top: instagram_button.bottom
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.topMargin: Theme.paddingMedium
                    model: photosInstagram
                    delegate: Item {
                        width: photos_grid.cellWidth
                        height: photos_grid.cellHeight

                        Image {
                            width: photos_grid.cellWidth/1.1
                            height: width
                            anchors.centerIn: parent
                            source: model.thumbnail
                            asynchronous: true
                            onStatusChanged:
                            {
                                if (status == Image.Loading)
                                {
                                    progressIndicator2.running = true
                                    photosInstagramCount++;
                                }
                                else if (status == Image.Error)
                                {
                                    source = '../images/noImage.png'
                                    progressIndicator2.running = false
                                    photosInstagram.remove(photos_grid.currentIndex)
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

            // Spacer
            Item {
                height: Theme.paddingLarge
                width: parent.width
            }
        }

        DockedPanel {
            id: matched_message
            open: matched  && !banned
            visible: matched  && !banned
            width: (parent.width*2)/3
            height: Math.max(pageColumn.height, Screen.height);
            dock: Dock.Right

            Column {
                id: panelColum
                spacing: Theme.paddingLarge
                anchors.centerIn: parent

                Label {
                    anchors.horizontalCenter: parent.horizontalCenter
                    wrapMode: Text.WordWrap
                    text: qsTr("Matched with:")
                }

                Label {
                    anchors.horizontalCenter: parent.horizontalCenter
                    wrapMode: Text.WordWrap
                    text: matched_name
                }

                Image {
                    width: Theme.itemSizeLarge
                    height: width
                    anchors.horizontalCenter: parent.horizontalCenter
                    source: matched_photo
                    asynchronous: true
                    smooth: true
                    onStatusChanged:
                    {
                        if (status == Image.Loading)
                        {
                            load_matched_photo.running = true
                        }
                        else if (status == Image.Error)
                        {
                            source = '../images/noImage.png'
                            load_matched_photo.running = false
                        }
                        else
                        {
                            load_matched_photo.running = false
                        }
                    }

                    BusyIndicator {
                        id: load_matched_photo
                        anchors.centerIn: parent
                        size: BusyIndicatorSize.Medium
                        running: true
                    }
                }

                Button {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: qsTr("Open People")
                    onClicked:
                    {
                        pageStack.push(Qt.resolvedUrl('PeoplePage.qml'));
                        matched = false
                    }
                }

                Button {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: qsTr("Swipe further")
                    onClicked: matched = false
                }
            }
        }

        ListModel {
            id: photosPeople
        }

        ListModel {
            id: photosInstagram
        }

        ViewPlaceholder {
            id: message
            enabled: true
            text: qsTr("Searching for people")
            hintText: qsTr("A moment please...")
        }

        Timer {
            id: api_reload
            running: false
            repeat: false
            interval: 5000
            onTriggered:
            {
                message.text = qsTr("Searching for people")
                message.hintText = qsTr("A moment please...")
                message.enabled = true
                cover_data.text = qsTr("Searching...")
                cover_data.image = '../images/harbour-sailfinder.png'
                cover_data.text_enabled = true
                cover_data.image_enabled = false
                cover_data.actions_enabled = false
                header.title = qsTr("Loading new people...")
                python.call('api.recommendations',[], function() {});
                person = 0;
            }
        }

        Timer {
            id: relogin
            running: false
            repeat: false
            interval: 1500
            onTriggered:
            {
                pageStack.replace(Qt.resolvedUrl('FirstPage.qml'));
            }
        }

        Timer {
            id: update_gps_tinder
            interval: 15000
            running: false
            repeat: true
            onTriggered:
            {
                python.call('api.update_location',[location.position.coordinate.latitude, location.position.coordinate.longitude], function(lat, lon) {})
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
                    update_gps_tinder.start()
                }
            }
        }

        Python {
            id: python
            Component.onCompleted:
            {
                python.call('api.recommendations',[], function() {});
                python.call('api.superlike_available',[], function() {});
                python.call('api.get_settings',[], function() {});

                // When Python has succesfully extracted the login data we can login into Tinder.
                setHandler('recommendations', function(recommendations)
                {

                    //console.log(JSON.stringify(recommendations))
                    if(recommendations) // If false, token expired
                    {
                        if(recommendations == "recs exhausted" || recommendations == "recs timeout")
                        {
                            python.call('api.profile',[], function() {});
                            message.text = qsTr("No new users in the area :-(")
                            message.hintText = qsTr("Extend your search criteria...")
                            message.enabled = true
                        }
                        else
                        {
                            people = recommendations
                            header.title = qsTr("Loading new people...")
                            loadPerson()
                            message.enabled = false
                        }
                    }
                    else
                    {
                        python.call('api.remove_tinder_token',[], function() {});
                        message.text = qsTr("Tinder login expired")
                        message.hintText = qsTr("Relogin please")
                        message.enabled = true
                        relogin.start()
                    }
                });

                setHandler('profile', function(profile_data) // Disable Sailfinder when the account has been banned by Tinder.
                {
                    //console.log(JSON.stringify(profile_data))
                    console.log(profile_data['banned'])
                    try {
                        banned = profile_data['banned']
                        if(banned)
                        {
                            message.text = qsTr("Account banned :-(")
                            message.hintText = qsTr("You can't use Sailfinder without a valid account")
                            message.enabled = true
                            cover_data.text = qsTr("Banned!")
                            cover_data.image = '../images/harbour-sailfinder.png'
                            cover_data.text_enabled = true
                            cover_data.image_enabled = true
                            cover_data.actions_enabled = false
                        }
                    }
                    catch(err)
                    {
                        console.log("[DEBUG] Banned:" + err)
                        console.log("[INFO] Banned = undefined means not banned!")
                    }
                });

                setHandler('settings', function(settings)
                {
                    //console.log(JSON.stringify(settings))
                    bio_enabled = parseInt(settings['bio']);
                    school_enabled = parseInt(settings['school']);
                    job_enabled = parseInt(settings['job']);
                    instagram_enabled = parseInt(settings['instagram']);
                });

                setHandler('dislike', function(result)
                {
                    try {
                        nextPerson()
                    }
                    catch(err)
                    {
                        console.log("[ERROR] Dislike:" + err)
                    }
                });

                setHandler('superlike', function(result)
                {
                    nextPerson()
                    console.log(JSON.stringify(result))
                    try {
                        matched = result['match']
                        matched_name = name
                        matched_photo = photos[0]['url']
                        if(matched)
                        {
                            console.log("[INFO] You and " + name + " supermatched!")
                            app.activate()
                        }
                    }
                    catch(err)
                    {
                        console.log("[ERROR] Superlike:" + err)
                    }
                });

                setHandler('superlike_available', function(superlike_reset_time)
                {
                    superLikeLimit = Helper.superlike_reseted(superlike_reset_time)
                });

                setHandler('like', function(result)
                {
                    nextPerson()
                    try {
                        matched = result['match']
                        matched_name = name
                        matched_photo = photos[0]['url']
                        if(matched)
                        {
                            console.log("[INFO] You and " + name + " matched!")
                            app.activate()
                        }

                    }
                    catch(err)
                    {
                        console.log("[ERROR] Like:" + err)
                    }
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
            onReceived:
            {
                console.log('Python MESSAGE: ' + JSON.stringify(data));
            }
        }
    }
}

