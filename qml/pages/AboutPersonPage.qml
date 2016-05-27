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

Page {
    id: page

    property variant picturesURL: ["../images/noImage.png", "../images/noImage.png", "../images/noImage.png", "../images/noImage.png", "../images/noImage.png", "../images/noImage.png"]
    property variant picturesVisible: [false, false, false, false, false, false]
    property bool isPerson: true
    property bool onlyFirstRow: true

    RemorsePopup {
        id: remorseTimer
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
                    id: savePulleyMenu
                    text: "Save"
                    visible: false
                    onClicked:
                    {
                        // Command Python to get the data and put in a file for later.
                    }
                }

                MenuItem {
                    id: deletePulleyMenu
                    text: "Delete"
                    visible: false
                    onClicked:
                    {
                        // Send the command to Python to delete this match
                        remorseTimer.execute("Unmatching", function() {
                            python.call('tinder.deleteMatch',[], function() {});
                            pageStack.pop();
                        });
                    }
                }

                MenuItem {
                    id: reportSpamPulleyMenu
                    text: "Report SPAM"
                    onClicked:
                    {
                        // Check if we are viewing a match or a person and send the right one to Python if the user wants to report this person/match.
                        remorseTimer.execute("Reporting for SPAM", function() {
                            if(isPerson)
                            {
                                // Spam -> #1
                                python.call('tinder.report',['person', 1], function(type, cause) {});
                            }
                            else
                            {
                                // Spam -> #1
                                python.call('tinder.report',['match', 1], function(type, cause) {});
                            }
                        });
                    }
                }

                MenuItem {
                    id: reportAbusivePulleyMenu
                    text: "Report INAPPROPRIATE"
                    onClicked:
                    {
                        // Check if we are viewing a match or a person and send the right one to Python if the user wants to report this person/match.
                        remorseTimer.execute("Reporting for INAPPROPRIATE", function() {
                            if(isPerson)
                            {
                                // Abusive -> #2
                                python.call('tinder.report',['person', 2], function(type, cause) {});
                            }
                            else
                            {
                                // Abusive -> #2
                                python.call('tinder.report',['match', 2], function(type, cause) {});
                            }
                        });
                    }
                }
            }

            PageHeader {
                title: qsTr("About this person")
            }
            Item {
                id: itemGridView
                width: page.width
                height: page.width

                Rectangle {
                    id: enlargedPicture
                    width: parent.width;
                    height: parent.width;
                    visible: false
                    color: "transparent"

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            gridViewPictures.visible = true
                            enlargedPicture.visible = false
                            if(onlyFirstRow)
                            {
                                itemGridView.height = 2*(page.width/3);
                            }
                        }
                    }

                    BusyIndicator {
                        id: loadingEnlargedPicture
                        running: true
                        size: BusyIndicatorSize.Medium
                        anchors.horizontalCenter: parent.horizontalCenter;
                        anchors.verticalCenter: parent.verticalCenter;
                        visible: true
                    }

                    Image {
                        id: pictureEnlarged
                        width: parent.width;
                        height: parent.height;
                        fillMode: Image.PreserveAspectFit
                        source: "../images/noImage.png"
                        onStatusChanged: {
                            if (status == Image.Error) {
                                source = "../images/noImage.png"
                                console.log('ERROR: pictureloading failed')
                            }

                            if(status == Image.Ready) {
                                loadingEnlargedPicture.visible = false;
                            }
                        }
                    }
                }

                Rectangle {
                    id: gridViewPictures
                    width: parent.width
                    height: parent.width
                    color: "transparent"

                    Column {
                        width: parent.width;

                        Row {
                            id: firstRowPictures
                            anchors.left: parent.left
                            anchors.right: parent.right

                            Rectangle {
                                width: parent.width - firstRowColumnPictures.width;
                                height: parent.width - firstRowColumnPictures.width;
                                color: "transparent";
                                Image {
                                    id: picturePersonAbout
                                    width: parent.width;
                                    height: parent.height;
                                    fillMode: Image.PreserveAspectFit
                                    source: picturesURL[0]
                                    visible: picturesVisible[0]
                                    onStatusChanged: {
                                        if (status == Image.Error) {
                                            source = "../images/noImage.png"
                                            console.log('ERROR: pictureloading failed')
                                        }

                                        if(status == Image.Ready) {
                                            loadingPicture.visible = false;
                                        }
                                    }
                                }

                                BusyIndicator {
                                    id: loadingPicture
                                    running: true
                                    size: BusyIndicatorSize.Small
                                    anchors.horizontalCenter: parent.horizontalCenter;
                                    anchors.verticalCenter: parent.verticalCenter;
                                    visible: true
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    enabled: picturePersonAbout.visible
                                    onClicked: {
                                        gridViewPictures.visible = false
                                        enlargedPicture.visible = true
                                        pictureEnlarged.source = picturePersonAbout.source
                                        itemGridView.height = page.width;
                                    }
                                }
                            }

                            Column {
                                id: firstRowColumnPictures
                                width: parent.width / 3;

                                Rectangle {
                                    width: parent.width;
                                    height: parent.width;
                                    color: "transparent";
                                    Image {
                                        id: picturePersonAbout1
                                        width: parent.width;
                                        height: parent.height;
                                        fillMode: Image.PreserveAspectFit
                                        source: picturesURL[1]
                                        visible: picturesVisible[1]
                                        onStatusChanged: {
                                            if (status == Image.Error) {
                                                source = "../images/noImage.png"
                                                console.log('ERROR: pictureloading failed')
                                            }

                                            if(status == Image.Ready) {
                                                loadingPicture1.visible = false;
                                            }
                                        }
                                    }

                                    BusyIndicator {
                                        id: loadingPicture1
                                        running: true
                                        size: BusyIndicatorSize.Small
                                        anchors.horizontalCenter: parent.horizontalCenter;
                                        anchors.verticalCenter: parent.verticalCenter;
                                        visible: true
                                    }

                                    MouseArea {
                                        id: touchPicture1
                                        anchors.fill: parent
                                        enabled: picturePersonAbout1.visible
                                        onClicked: {
                                            gridViewPictures.visible = false
                                            enlargedPicture.visible = true
                                            pictureEnlarged.source = picturePersonAbout1.source
                                            itemGridView.height = page.width;
                                        }
                                    }
                                }

                                Rectangle {
                                    width: parent.width;
                                    height: parent.width;
                                    color: "transparent";
                                    Image {
                                        id: picturePersonAbout2
                                        width: parent.width;
                                        height: parent.height;
                                        fillMode: Image.PreserveAspectFit
                                        source: picturesURL[2]
                                        visible: picturesVisible[2]
                                        onStatusChanged: {
                                            if (status == Image.Error) {
                                                source = "../images/noImage.png"
                                                console.log('ERROR: pictureloading failed')
                                            }

                                            if(status == Image.Ready) {
                                                loadingPicture2.visible = false;
                                            }
                                        }
                                    }

                                    BusyIndicator {
                                        id: loadingPicture2
                                        running: true
                                        size: BusyIndicatorSize.Small
                                        anchors.horizontalCenter: parent.horizontalCenter;
                                        anchors.verticalCenter: parent.verticalCenter;
                                        visible: true
                                    }

                                    MouseArea {
                                        id: touchPicture2
                                        anchors.fill: parent
                                        enabled: picturePersonAbout2.visible
                                        onClicked: {
                                            gridViewPictures.visible = false
                                            enlargedPicture.visible = true
                                            pictureEnlarged.source = picturePersonAbout2.source
                                            itemGridView.height = page.width;
                                        }
                                    }
                                }
                            }
                        }

                        Row {
                            id: secondRowPictures
                            anchors.left: parent.left
                            anchors.right: parent.right
                            visible: false

                            Rectangle {
                                width: parent.width / 3;
                                height: parent.width / 3;
                                color: "transparent";
                                Image {
                                    id: picturePersonAbout3
                                    width: parent.width;
                                    height: parent.height;
                                    fillMode: Image.PreserveAspectFit
                                    source: picturesURL[3]
                                    visible: picturesVisible[3]
                                    onStatusChanged: {
                                        if (status == Image.Error) {
                                            source = "../images/noImage.png"
                                            console.log('ERROR: pictureloading failed')
                                        }

                                        if(status == Image.Ready) {
                                            loadingPicture3.visible = false;
                                        }
                                    }
                                }

                                BusyIndicator {
                                    id: loadingPicture3
                                    running: true
                                    size: BusyIndicatorSize.Small
                                    anchors.horizontalCenter: parent.horizontalCenter;
                                    anchors.verticalCenter: parent.verticalCenter;
                                    visible: true
                                }

                                MouseArea {
                                    id: touchPicture3
                                    anchors.fill: parent
                                    enabled: picturePersonAbout3.visible
                                    onClicked: {
                                        gridViewPictures.visible = false
                                        enlargedPicture.visible = true
                                        pictureEnlarged.source = picturePersonAbout3.source
                                    }
                                }
                            }

                            Rectangle {
                                width: parent.width / 3;
                                height: parent.width / 3;
                                color: "transparent";
                                Image {
                                    id: picturePersonAbout4
                                    width: parent.width;
                                    height: parent.height;
                                    fillMode: Image.PreserveAspectFit
                                    source: picturesURL[4]
                                    visible: picturesVisible[4]
                                    onStatusChanged: {
                                        if (status == Image.Error) {
                                            source = "../images/noImage.png"
                                            console.log('ERROR: pictureloading failed')
                                        }

                                        if(status == Image.Ready) {
                                            loadingPicture4.visible = false;
                                        }
                                    }
                                }

                                BusyIndicator {
                                    id: loadingPicture4
                                    running: true
                                    size: BusyIndicatorSize.Small
                                    anchors.horizontalCenter: parent.horizontalCenter;
                                    anchors.verticalCenter: parent.verticalCenter;
                                    visible: true
                                }

                                MouseArea {
                                    id: touchPicture4
                                    anchors.fill: parent
                                    enabled: picturePersonAbout4.visible
                                    onClicked: {
                                        gridViewPictures.visible = false
                                        enlargedPicture.visible = true
                                        pictureEnlarged.source = picturePersonAbout4.source
                                    }
                                }
                            }

                            Rectangle {
                                width: parent.width / 3;
                                height: parent.width / 3;
                                color: "transparent";
                                Image {
                                    id: picturePersonAbout5
                                    width: parent.width;
                                    height: parent.height;
                                    fillMode: Image.PreserveAspectFit
                                    source: picturesURL[5]
                                    visible: picturesVisible[5]
                                    onStatusChanged: {
                                        if (status == Image.Error) {
                                            source = "../images/noImage.png"
                                            console.log('ERROR: pictureloading failed')
                                        }

                                        if(status == Image.Ready) {
                                            loadingPicture5.visible = false;
                                        }
                                    }
                                }

                                BusyIndicator {
                                    id: loadingPicture5
                                    running: true
                                    size: BusyIndicatorSize.Small
                                    anchors.horizontalCenter: parent.horizontalCenter;
                                    anchors.verticalCenter: parent.verticalCenter;
                                    visible: true
                                }

                                MouseArea {
                                    id: touchPicture5
                                    anchors.fill: parent
                                    enabled: picturePersonAbout5.visible
                                    onClicked: {
                                        gridViewPictures.visible = false
                                        enlargedPicture.visible = true
                                        pictureEnlarged.source = picturePersonAbout5.source
                                    }
                                }
                            }
                        }
                    }
                }
            }

            // Spacer
            Rectangle {
                width: parent.width
                height: 30
                color: "transparent"
            }

            Row {
                id: nameAgeDistanceGenderRow
                spacing: Theme.paddingMedium
                anchors {
                    left: column.left
                    right: column.right
                    leftMargin: Theme.horizontalPageMargin
                    rightMargin: Theme.horizontalPageMargin
                }

                Label {
                    id: nameAgeDistancePersonAbout
                    color: Theme.highlightColor
                    text: ""
                }

                Image {
                    id: genderIcon
                    width: nameAgeDistancePersonAbout.height
                    height: nameAgeDistancePersonAbout.height
                    visible: false
                    source: "../images/male.png"
                }
            }

            Column {
                id: lastOnline
                width: parent.width

                Row {
                    id: lastOnlineRow
                    spacing: Theme.paddingMedium
                    anchors {
                        right: parent.right
                        rightMargin: Theme.horizontalPageMargin
                    }

                    Label {
                        id: lastOnlineHeader
                        color: Theme.highlightColor
                        font.pixelSize: Theme.fontSizeSmall
                        text: "Last online"
                    }

                    Image {
                        id: lastOnlineIcon
                        width: lastOnlineHeader.height
                        height: lastOnlineHeader.height
                        source: "../images/lastOnline.png"
                    }
                }

                Label {
                    id: lastOnlinePersonAbout
                    anchors {
                        left: parent.left
                        right: parent.right
                        leftMargin: Theme.horizontalPageMargin
                        rightMargin: Theme.horizontalPageMargin
                    }
                    wrapMode: Text.WordWrap
                    text: ""
                }
            }

            Column {
                id: school
                width: parent.width

                Row {
                    id: schoolRow
                    spacing: Theme.paddingMedium
                    anchors {
                        right: parent.right
                        rightMargin: Theme.horizontalPageMargin
                    }

                    Label {
                        id: schoolHeader
                        color: Theme.highlightColor
                        font.pixelSize: Theme.fontSizeSmall
                        text: "School"
                    }

                    Image {
                        id: schoolIcon
                        width: schoolHeader.height
                        height: schoolHeader.height
                        source: "../images/school.png"
                    }
                }

                Label {
                    id: schoolPersonAbout
                    anchors {
                        left: parent.left
                        right: parent.right
                        leftMargin: Theme.horizontalPageMargin
                        rightMargin: Theme.horizontalPageMargin
                    }
                    wrapMode: Text.WordWrap
                    text: ""
                }
            }

            Column {
                id: job
                width: parent.width

                Row {
                    id: jobRow
                    spacing: Theme.paddingMedium
                    anchors {
                        right: parent.right
                        rightMargin: Theme.horizontalPageMargin
                    }

                    Label {
                        id: jobHeader
                        color: Theme.highlightColor
                        font.pixelSize: Theme.fontSizeSmall
                        text: "Job"
                    }

                    Image {
                        id: jobIcon
                        width: jobHeader.height
                        height: jobHeader.height
                        source: "../images/job.png"
                    }
                }

                Label {
                    id: jobPersonAbout
                    anchors {
                        left: parent.left
                        right: parent.right
                        leftMargin: Theme.horizontalPageMargin
                        rightMargin: Theme.horizontalPageMargin
                    }
                    wrapMode: Text.WordWrap
                    text: ""
                }
            }

            Column {
                id: instagram
                width: parent.width

                Row {
                    id: instagramRow
                    spacing: Theme.paddingMedium
                    anchors {
                        right: parent.right
                        rightMargin: Theme.horizontalPageMargin
                    }

                    Label {
                        id: instagramHeader
                        color: Theme.highlightColor
                        font.pixelSize: Theme.fontSizeSmall
                        text: "Instagram"
                    }

                    Image {
                        id: instagramIcon
                        width: instagramHeader.height
                        height: instagramHeader.height
                        source: "../images/instagram.png"
                    }
                }

                Label {
                    id: instagramPersonAbout
                    anchors {
                        left: parent.left
                        leftMargin: Theme.horizontalPageMargin
                    }
                }
            }

            Column {
                id: bio
                width: parent.width

                Row {
                    id: bioRow
                    spacing: Theme.paddingMedium
                    anchors {
                        right: parent.right
                        rightMargin: Theme.horizontalPageMargin
                    }

                    Label {
                        id: bioHeader
                        color: Theme.highlightColor
                        font.pixelSize: Theme.fontSizeSmall
                        text: "Bio"
                    }

                    Image {
                        id: bioIcon
                        width: jobHeader.height
                        height: jobHeader.height
                        source: "../images/bio.png"
                    }
                }

                Label {
                    id: bioPersonAbout
                    text: ""
                    wrapMode: Text.WordWrap
                    anchors {
                        left: parent.left
                        right: parent.right
                        leftMargin: Theme.horizontalPageMargin
                        rightMargin: Theme.horizontalPageMargin
                    }
                }
            }
        }

        ListModel {
            id: picturesModel
        }

        Python {
            id: python
            Component.onCompleted:
            {
                addImportPath(Qt.resolvedUrl('.'));
                importModule('tinder', function() {});

                setHandler('getDataAbout', function(type, name, age, gender, distance, day, month, year, time, about, instagram_username, schools, jobs)
                {
                    // Name, age and distance.
                    nameAgeDistancePersonAbout.text = name + ' ('+ age + ')' + ' - ' + distance + ' km away';

                    // Show the right gender icon.
                    if(gender == 'male')
                    {
                        genderIcon.source = "../images/male.png"
                    }
                    else
                    {
                        genderIcon.source = "../images/female.png"
                    }
                    genderIcon.visible = true;

                    // Show the last time this person was online.
                    lastOnlinePersonAbout.text = time + ' - ' + day + '/' + month + '/' + year;

                    // If available, show the instagram username.
                    if(instagram_username)
                    {
                        instagramPersonAbout.text = instagram_username;
                        instagram.visible = true;
                    }
                    else
                    {
                        instagram.visible = false;
                    }

                    // If available, show the schools.
                    if(schools)
                    {
                        schoolPersonAbout.text = schools;
                        school.visible = true;
                    }
                    else
                    {
                        school.visible = false;
                    }

                    // If available, show the jobs.
                    if(jobs)
                    {
                        jobPersonAbout.text = jobs;
                        job.visible = true;
                    }
                    else
                    {
                        job.visible = false;
                    }

                    // If available, show the bio.
                    if(about)
                    {
                        bioPersonAbout.text = about;
                        bio.visible = true;
                    }
                    else
                    {
                        bio.visible = false;
                    }

                    if(type == 'match')
                    {
                        pullDownMenu.visible = true;
                        deletePulleyMenu.visible = true;
                        reportSpamPulleyMenu.visible = true;
                        reportAbusivePulleyMenu.visible = true;
                        isPerson = false;
                    }
                    else
                    {
                        pullDownMenu.visible = false;
                        deletePulleyMenu.visible = false;
                        reportSpamPulleyMenu.visible = false;
                        reportAbusivePulleyMenu.visible = false;
                        isPerson = true;
                    }
                });


                setHandler('getPictures', function(pictureNumber, picture)
                {
                    // Copy the QML variant picturesURL to Javascript to modify it.
                    var copyToJavascript = picturesURL;

                    // Write our change and save it again as a QML variant.
                    copyToJavascript[pictureNumber] = picture;
                    picturesURL = copyToJavascript;

                    // Repeat it for picturesVisible.
                    copyToJavascript = picturesVisible;
                    copyToJavascript[pictureNumber] = true;
                    picturesVisible = copyToJavascript;

                    // If we have more then 3 pictures, enlarge our gridViewPictures and show the second row of pictures.
                    if(pictureNumber < 3) {
                        gridViewPictures.height = firstRowPictures.height;
                        itemGridView.height = 2*(page.width/3);
                        onlyFirstRow = true;
                    }
                    else
                    {
                        gridViewPictures.height = page.width;
                        itemGridView.height = page.width;
                        secondRowPictures.visible = true;
                        onlyFirstRow = false;
                    }
                });
            }

            onError: {
                console.log('Python ERROR: ' + traceback);
                Clipboard.text = traceback;
                pageStack.completeAnimation();
                pageStack.replace(Qt.resolvedUrl('ErrorPage.qml'));
                pageStack.completeAnimation();
            }

            //DEBUG
            /*onReceived: {
                console.log('Python MESSAGE: ' + data);
            }*/
        }
    }
}
