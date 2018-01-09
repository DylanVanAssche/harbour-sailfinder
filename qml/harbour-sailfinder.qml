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

import QtQuick 2.0
import Sailfish.Silica 1.0
import "pages"

ApplicationWindow
{
    id: app
    initialPage: Component { FirstPage { } }
    cover: Qt.resolvedUrl("cover/CoverPage.qml")
    allowedOrientations: defaultAllowedOrientations

    readonly property string fbAuthUrl: "https://www.facebook.com/login.php?skip_api_login=1&api_key=464891386855067&signed_next=1&next=https%3A%2F%2Fwww.facebook.com%2Fv2.8%2Fdialog%2Foauth%3Fchannel%3Dhttps%253A%252F%252Fstaticxx.facebook.com%252Fconnect%252Fxd_arbiter%252Fr%252FlY4eZXm_YWu.js%253Fversion%253D42%2523cb%253Dff93d650476534%2526domain%253Dtinder.com%2526origin%253Dhttps%25253A%25252F%25252Ftinder.com%25252Ff30775c0d5a2d48%2526relation%253Dopener%26redirect_uri%3Dhttps%253A%252F%252Fstaticxx.facebook.com%252Fconnect%252Fxd_arbiter%252Fr%252FlY4eZXm_YWu.js%253Fversion%253D42%2523cb%253Df20472322e9714%2526domain%253Dtinder.com%2526origin%253Dhttps%25253A%25252F%25252Ftinder.com%25252Ff30775c0d5a2d48%2526relation%253Dopener%2526frame%253Df1b408914e2b544%26display%3Dpopup%26scope%3Duser_birthday%252Cuser_photos%252Cuser_education_history%252Cemail%252Cuser_relationship_details%252Cuser_friends%252Cuser_work_history%252Cuser_likes%26response_type%3Dtoken%252Csigned_request%26domain%3Dtinder.com%26origin%3D1%26client_id%3D464891386855067%26ret%3Dlogin%26sdk%3Djoey%26logger_id%3D3c819d58-066f-d4f9-a74f-75baac9ccd8f&cancel_url=https%3A%2F%2Fstaticxx.facebook.com%2Fconnect%2Fxd_arbiter%2Fr%2FlY4eZXm_YWu.js%3Fversion%3D42%23cb%3Df20472322e9714%26domain%3Dtinder.com%26origin%3Dhttps%253A%252F%252Ftinder.com%252Ff30775c0d5a2d48%26relation%3Dopener%26frame%3Df1b408914e2b544%26error%3Daccess_denied%26error_code%3D200%26error_description%3DPermissions%2Berror%26error_reason%3Duser_denied%26e2e%3D%257B%257D&display=popup&locale=en_GB&logger_id=3c819d58-066f-d4f9-a74f-75baac9ccd8f"
    readonly property string userAgent: "Mozilla/5.0 (Linux; Android 8.0.0; Nexus 6P Build/OPR6.170623.013) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/60.0.3112.116 Mobile Safari/537.36"
}

