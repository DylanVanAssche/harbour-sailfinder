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

Dialog {
    id: dialog

    SilicaFlickable {
        anchors.fill: parent
        contentHeight: column.height

        Column {
            id: column
            width: parent.width

            DialogHeader { }

            SectionHeader { text: "Pictures" }

            Label {
                anchors {
                    left: parent.left
                    right: parent.right
                    leftMargin: Theme.horizontalPageMargin
                    rightMargin: Theme.horizontalPageMargin
                }
                wrapMode: Text.WordWrap
                text: "This feature isn't available in Pynder yet. Feel free to contact me if you want to help to implent it or send a pull request to Pynder on Github with a solution."
            }

           /* Button {
                text: 'Upload profilepicture'
                onClicked: python.call('tinder.uploadPictureProfile',[], function() {});
            }*/

            SectionHeader { text: "Bio & gender" }

            TextArea {
                id: bio
                width: parent.width
                height: Math.max(parent.width/3, implicitHeight)
                placeholderText: "Type your bio here."
            }

            ComboBox {
                id: gender
                width: parent.width
                label: "Gender: "
                currentIndex: 1
                menu: ContextMenu {
                    MenuItem { text: "Male" }
                    MenuItem { text: "Female" }
                }
            }

            Python {
                id: python
                Component.onCompleted:
                {
                    // Add the Python path to PyOtherSide and import our module 'tinder'.
                    addImportPath(Qt.resolvedUrl('.'));
                    importModule('tinder', function() {});

                    // When Python is ready, load our profile...
                    python.call('tinder.loadProfile',[0, true], function(pictureNumber, firstPass) {});

                    // Get our profile data.
                    setHandler('getProfileData', function(name, bioText, genderIndex)
                    {
                        gender.currentIndex = genderIndex;
                        bio.text = bioText;
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
    }

    onDone:
    {
        if (result == DialogResult.Accepted)
        {
            python.call('tinder.updateProfile',[bio.text, gender.currentIndex], function(bio, gender) {});
        }
    }
}
