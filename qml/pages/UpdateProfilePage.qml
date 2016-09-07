import QtQuick 2.2
import Sailfish.Silica 1.0
import io.thp.pyotherside 1.3

Dialog {
    id: dialog

    property bool delete_username
    property bool share_link_available
    property bool selected
    property var photo_id_selected

    // Sailfinder API
    property var profile
    property var my_tinder_id
    property var photos
    property var bio_text
    property var gender_value
    property var interested_in_value
    property var username_text
    property var age_max_value
    property var age_min_value
    property bool discoverable_bool
    property var search_distance_value
    property var share_url: qsTr("N/A")
    property var share_text: qsTr("N/A")

    function load_profile()
    {
        try {
            my_tinder_id = profile['_id']
            bio_text = profile['bio']
            photos = profile['photos']
            gender_value = profile['gender']
            username_text = profile['username']
            interested_in_value = profile['gender_filter']
            age_max_value = profile['age_filter_max']
            age_min_value = profile['age_filter_min']
            discoverable_bool = profile['discoverable']
            search_distance_value = profile['distance_filter'] * 1.609344
            //current_position = profile['pos']
            //standard_position = profile['pos_major']
            //schools = profile['schools']
            //high_school = profile['high_school']
            //college = profile["college"] //FB ID COLLEGE
            //jobs = profile['jobs']

            bio.text = bio_text
            gender.currentIndex = gender_value
            interested_in.currentIndex = interested_in_value+1
            username.text = username_text
            age_filter_max.value = age_max_value
            age_filter_min.value = age_min_value
            discoverable.checked = discoverable_bool
            search_distance.value = search_distance_value
        }
        catch(err)
        {
            console.log("[ERROR] Can't load profile settings: " + err)
        }

        try {
        if(username_text.length > 0)
        {
            loading_share_url.running = true;
            python.call('api.share_link',[my_tinder_id], function(my_tinder_id) {});
        }
        }
        catch(err)
        {
            console.log("[INFO] No username chosen yet.")
        }

        load_photos()
    }

    function check_username()
    {
        if(username.text != username_text)
        {
            if(username_text.length > 0)
            {
                console.log('UPDATE username')
                python.call('api.update_username',[username.text], function() {});
            }
            else
            {
                console.log('CREATE username')
                python.call('api.create_username',[username.text], function() {});
            }
        }

        if(delete_username)
        {
            console.log('DELETE username')
            python.call('api.delete_username',[], function() {});
        }
    }

    function load_photos()
    {
        photosProfile.clear(); // Clear the photos when we update
        for (var i = 0; i < 6; i++)
        {
            photosProfile.append({url: "../images/noImage.png", text: '', tinder_photo_id: 'no_image_available'});
        }

        for (var i = 0; i < Object.keys(photos).length; i++)
        {
            photosProfile.set(i, {url: photos[i]['url'], text: '', tinder_photo_id: photos[i]['id']});
        }

        // Buttons
        photosProfile.set(6, {url: "image://theme/icon-m-cloud-upload", text: qsTr("Facebook"), tinder_photo_id: 'fb'});
        photosProfile.set(7, {url: "image://theme/icon-m-device-upload", text: qsTr("Local"), tinder_photo_id: 'local'});
        photosProfile.set(8, {url: "image://theme/icon-m-delete", text: qsTr("Delete"), tinder_photo_id: 'delete'});
    }

    SilicaFlickable {
        anchors.fill: parent
        contentHeight: pageColumn.height

        Column {
            id: pageColumn
            width: parent.width
            spacing: Theme.paddingLarge

            RemorsePopup {
                id: remorse
            }

            DialogHeader {
                acceptText: qsTr("Save")
                title: qsTr("Update profile")
            }

            SectionHeader { text: qsTr("Photos") }

            Label {
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.leftMargin: Theme.horizontalPageMargin
                anchors.rightMargin: Theme.horizontalPageMargin
                font.pixelSize: Theme.fontSizeSmall
                wrapMode: Text.WordWrap
                text: if(selected)
                      {
                          if(photo_id_selected == 'no_image_available')
                          {
                              qsTr("Upload a new picture")
                          }
                          else
                          {
                              qsTr("Delete this picture")
                          }
                      }
                      else
                      {
                          qsTr("Select a picture")
                      }
            }

            SilicaGridView {
                id: gallery
                width: parent.width
                height: width
                cellWidth: parent.width/3
                cellHeight: cellWidth
                model: photosProfile

                delegate: BackgroundItem {
                    width: gallery.cellWidth
                    height: gallery.cellHeight
                    enabled:
                    {
                        if(model.tinder_photo_id != 'local')
                        {
                            true
                        }
                        else
                        {
                            false
                        }
                    }

                    onClicked:
                    {
                        if(model.tinder_photo_id.length > 10) // filter out our own IDs
                        {
                            if(photo_id_selected == model.tinder_photo_id || !selected)
                            {
                                selectedPhoto.visible = !selectedPhoto.visible;
                                if(selectedPhoto.visible)
                                {
                                    photo_id_selected = model.tinder_photo_id;
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
                            switch(model.tinder_photo_id)
                            {
                            case 'fb':
                                if(selected)
                                {
                                    pageStack.replace(Qt.resolvedUrl('GalleryPage.qml'), {type: 'fb'});
                                }
                                break;

                            case 'local':
                                console.log("UPLOAD WITH LOCAL")
                                //python.call('api.upload_picture',[], function() {});
                                break;

                            case 'delete':
                                if(selected)
                                {
                                    remorse.execute("Deleting picture", function()
                                    {
                                        python.call('api.delete_picture',[photo_id_selected], function(tinder_photo_id) {}); // Delete image
                                        python.call('api.profile', [], function() {}); // Reload profile data with new images
                                        selected = false
                                        photo_id_selected = ""
                                    })
                                }
                                break;
                            }
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
                        id: image
                        width:
                        {
                            if(model.text.length)
                            {
                                Theme.iconSizeMedium
                            }
                            else
                            {
                                gallery.cellWidth/1.1
                            }
                        }
                        height: width
                        anchors.centerIn: parent
                        source: model.url
                        fillMode: Image.PreserveAspectCrop
                        asynchronous: true
                        smooth: true
                        antialiasing: true
                        opacity:
                        {
                            if(model.tinder_photo_id != 'local')
                            {
                                1.0
                            }
                            else
                            {
                                0.2
                            }
                        }

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

                    Label {
                        anchors.top: image.bottom
                        anchors.topMargin: Theme.paddingMedium
                        anchors.horizontalCenter: parent.horizontalCenter
                        visible: model.text.length
                        text: model.text
                        opacity:
                        {
                            if(model.tinder_photo_id != 'local')
                            {
                                1.0
                            }
                            else
                            {
                                0.2
                            }
                        }
                    }
                }
            }

            SectionHeader { text: qsTr("Bio") }

            TextArea {
                id: bio
                width: parent.width
                height: Math.max(parent.width/3, implicitHeight)
                placeholderText: qsTr("Type your bio here.")
                label: qsTr("Your bio (max 500 characters)")
                onTextChanged:
                {
                    if(text.length > 500)
                    {
                        dialog.canAccept = false
                        bio.color = "red"
                    }
                    else
                    {
                        dialog.canAccept = true
                        bio.color = Theme.primaryColor
                    }
                }
            }

            SectionHeader { text: qsTr("Gender") }

            ComboBox {
                id: gender
                width: parent.width
                label: "Gender: "
                currentIndex: -1
                menu: ContextMenu {
                    MenuItem { text: qsTr("Male") }
                    MenuItem { text: qsTr("Female") }
                }
            }

            SectionHeader { text: qsTr("Username") }

            Column {
                width: parent.width
                spacing: Theme.paddingLarge

                TextField {
                    id: username
                    width: parent.width
                    font.capitalization: Font.AllLowercase // All the usernames are set with lowercase characters
                    placeholderText: qsTr("Tinder username")
                    label: qsTr("Share your profile now!")
                }


                Item {
                    width: parent.width
                    height: get_share_link_button.height

                    Button {
                        id: get_share_link_button
                        anchors.horizontalCenter: parent.horizontalCenter
                        enabled: username.text.length
                        text: qsTr("Get share URL")
                        onClicked:
                        {
                            loading_share_url.running = true;
                            check_username();
                            username_text = username.text
                            python.call('api.share_link',[my_tinder_id], function(my_tinder_id) {});
                        }
                    }

                    BusyIndicator {
                        id: loading_share_url
                        size: BusyIndicatorSize.Small
                        anchors.right: get_share_link_button.left
                        anchors.rightMargin: Theme.paddingMedium
                        anchors.verticalCenter: parent.verticalCenter
                        running: false
                    }
                }

                Row {
                    width: parent.width
                    anchors {
                        left: parent.left
                        right: parent.right
                        leftMargin: Theme.horizontalPageMargin
                        rightMargin: Theme.horizontalPageMargin
                    }
                    spacing: Theme.paddingSmall
                    visible: share_link_available && !delete_username

                    IconButton {
                        icon.source: "image://theme/icon-m-clipboard?" + (pressed? Theme.highlightColor: Theme.primaryColor)
                        onClicked: Clipboard.text = share_url
                    }
                    TextArea {
                        width: parent.width - Theme.iconSizeMedium
                        readOnly: true
                        font.pixelSize: Theme.fontSizeSmall
                        label: qsTr("My share URL")
                        text: share_url
                    }
                }

                TextArea {
                    width: parent.width
                    readOnly: true
                    font.pixelSize: Theme.fontSizeSmall
                    label: qsTr("Share text")
                    visible: share_link_available && !delete_username
                    text: share_text
                }

                Button {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: qsTr("Delete username")
                    color: "red"
                    enabled: username_text || share_link_available
                    onClicked:
                    {
                        remorse.execute("Deleting username", function()
                        {
                            delete_username = true;
                            check_username();
                            username_text = '';
                            username.visible = true
                            get_share_link_button.visible = true
                        })
                    }
                }
            }

            Label {
                id: username_deleted
                anchors.horizontalCenter: parent.horizontalCenter
                wrapMode: Text.WordWrap
                visible: false
                text: qsTr("Username succesfully deleted!")
            }

            SectionHeader { text: qsTr("Discoverable") }

            IconTextSwitch {
                id: discoverable
                icon.source: "image://theme/icon-m-share"
                text: qsTr("Discovery")
                description: qsTr("Choose if other people can see your Tinder profile or not. This has no effect on your matches you already have. When disabled, you can't change your search criteria.")
                checked: false
            }

            SectionHeader { text: qsTr("Search criteria") }

            ComboBox {
                id: interested_in
                width: parent.width
                label: qsTr("Interested in: ")
                currentIndex: -1
                visible: discoverable.checked
                menu: ContextMenu {
                    MenuItem { text: qsTr("Everyone") }
                    MenuItem { text: qsTr("Male") }
                    MenuItem { text: qsTr("Female") }
                }
            }

            Slider {
                id: age_filter_min
                width: parent.width
                value: 18
                minimumValue: 18
                maximumValue: 100
                stepSize: 2
                valueText: value.toFixed(0)
                label: qsTr("Minimum age")
                visible: discoverable.checked
                onReleased:
                {
                    if(value > age_filter_max.value)
                    {
                        value = age_filter_max.value
                    }
                }
            }

            Slider {
                id: age_filter_max
                width: parent.width
                value: 100
                minimumValue: 18
                maximumValue: 100
                stepSize: 2
                valueText: value.toFixed(0)
                label: qsTr("Maximum age")
                visible: discoverable.checked
                onReleased:
                {
                    if(value < age_filter_min.value)
                    {
                        value = age_filter_min.value
                    }
                }
            }

            Slider {
                id: search_distance
                width: parent.width
                value: 160
                minimumValue:2
                maximumValue:160
                stepSize: 2
                valueText: value.toFixed(0) + " km"
                label: qsTr("Search distance")
                visible: discoverable.checked
            }

            Label {
                visible: !discoverable.checked
                wrapMode: Text.WordWrap
                font.pixelSize: Theme.fontSizeLarge
                anchors {
                    left: parent.left
                    right: parent.right
                    leftMargin: Theme.horizontalPageMargin
                    rightMargin: Theme.horizontalPageMargin
                }
                text: qsTr("Enable discovery to change the search criteria.")
            }

            // Spacer
            Item {
                height: 20
                width: parent.width
            }

            VerticalScrollDecorator {}
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

                // When Python is ready, load our profile...
                python.call('api.profile',[], function() {});

                setHandler('profile', function(profile_data)
                {
                    profile = profile_data;
                    load_profile();
                });

                setHandler('username', function(result)
                {
                    switch(result)
                    {
                    case false: // ERROR
                        username.color = "red"
                        username.label = qsTr("Username already in use!")
                        share_link_available = false
                        break;
                    case 1: // CREATED
                        username_deleted.visible = false;
                        username.color = Theme.primaryColor
                        username.label = qsTr("Username created!")
                        break;
                    case 2: // UPDATED
                        username_deleted.visible = false;
                        username.color = Theme.primaryColor
                        username.label = qsTr("Username changed!")
                        break;
                    case 3: // DELETED
                        username_deleted.visible = true;
                        username.color = Theme.primaryColor
                        username.label = qsTr("Username deleted!")
                        break;
                    }
                });

                setHandler('sharelink', function(url)
                {
                    if(url)
                    {
                        share_link_available = true
                        share_url = url['link']
                        share_text = url['share_text']
                        loading_share_url.running = false
                    }
                });

                setHandler('fb_photos', function(fb_photos_data)
                {
                    console.log(JSON.stringify(fb_photos_data))
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
    }

    onDone:
    {
        if (result == DialogResult.Accepted)
        {
            // Only update if the user changed something
            if(bio.text != bio_text || gender.currentIndex != gender_value ||discoverable.checked != discoverable_bool || interested_in.currentIndex-1 != interested_in_value ||age_filter_min.value != age_min_value || age_filter_max.value != age_max_value || search_distance.value != search_distance_value)
            {
                python.call('api.update_profile',[discoverable.checked, age_filter_min.value, age_filter_max.value, gender.currentIndex, interested_in.currentIndex-1, search_distance.value/1.609344, bio.text], function(discoverable, age_min, age_max, gender, gender_filter, distance, bio) {});
            }

            check_username()
        }
    }
}


