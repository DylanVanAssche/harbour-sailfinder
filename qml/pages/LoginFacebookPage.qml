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
import QtWebKit 3.0
import Sailfish.Silica 1.0
import io.thp.pyotherside 1.3

Page {
    id: loginFacebookPage

    SilicaWebView {
        id: webView
        width: parent.width
        height: parent.height
        anchors
        {
            top: parent.top
            left: parent.left
            right: parent.right
            bottom: parent.bottom
        }
        focus: true
        url: "https://www.facebook.com/dialog/oauth?client_id=464891386855067&redirect_uri=https://www.facebook.com/connect/login_success.html&scope=basic_info,email,public_profile,user_about_me,user_activities,user_birthday,user_education_history,user_friends,user_interests,user_likes,user_location,user_photos,user_relationship_details&response_type=token"
        onLoadingChanged:
        {
            // When the URL has been changed, send it to Python to check if it contains an ACCESS TOKEN.
            if(loadRequest.status == WebView.LoadSucceededStatus)
            {
                python.call('tinder.login',[loadRequest.url.toString()], function(url) {});
            }
        }

        Python {
            id: python
            Component.onCompleted:
            {
                // Add the Python path to PyOtherSide and import our module 'tinder'.
                addImportPath(Qt.resolvedUrl('.'));
                importModule('tinder', function() {});

                // When Python has succesfully extracted the login data we can login into Tinder.
                setHandler('loginFacebookSuccesfully', function(success)
                {
                    if(success)
                    {
                        // Complete any previous pageStack operations and load the LoginTinderPage.
                        pageStack.completeAnimation()
                        pageStack.replace(Qt.resolvedUrl('LoginTinderPage.qml'));
                        pageStack.completeAnimation()
                    }
                    else
                    {
                        // When Python couldn't receive the USER-ID from the Facebook Graph API then we should try to login in again.
                        webView.url = "https://www.facebook.com/dialog/oauth?client_id=464891386855067&redirect_uri=https://www.facebook.com/connect/login_success.html&scope=basic_info,email,public_profile,user_about_me,user_activities,user_birthday,user_education_history,user_friends,user_interests,user_likes,user_location,user_photos,user_relationship_details&response_type=token"
                    }
                });

                // Sailfish OS doesn't want to handle my own exceptions so I implented a workaround:
                setHandler('ERROR', function(traceback)
                {
                    Clipboard.text = traceback
                    pageStack.completeAnimation();
                    pageStack.replace(Qt.resolvedUrl('ErrorPage.qml'));
                    pageStack.completeAnimation();
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
}


