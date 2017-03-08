# Tinder API
 _with Python Requests_

**Inspired by <a href="https://gist.github.com/rtt/10403467">this</a> Github Gist and the rest is sniffed by myself.**


### API Details

<table>
  <tbody>
    <tr>
      <td>Host</td>
      <td>api.gotinder.com</td>
    </tr>
    <tr>
      <td>Protocol</td>
      <td>SSL only</td>
    </tr>
  </tbody>
</table>

*'api.gotinder.com' will be refered in this document as TINDER_HOST*

<b>Request headers</b>

<table>
  <thead>
    <tr>
      <th>Header name</th>
      <th>Description</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td>X-Auth-Token</td>
      <td>A <a href="http://en.wikipedia.org/wiki/Universally_unique_identifier#Version_4_.28random.29">UUID4</a> format authentication token obtained via the /auth api endpoint</td>
    </tr>
    <tr>
      <td>Content-type</td>
      <td>application/json</td>
    </tr>
    <tr>
    	<td>app_version</td>
    	<td>371</td>
    </tr>
    <tr>
    	<td>platform</td>
    	<td>ios</td>
    </tr>
    <tr>
    	<td>User-agent</td>
    	<td>User-Agent: Tinder/4.6.1 (iPhone; iOS 9.0.1; Scale/2.00)</td>
    </tr>
    <tr>
    	<td>os_version</td>
    	<td>900001</td>
    </tr>
  </tbody>
</table>

All Python Requests examples need these headers!
You can add these by running this command, after you established your session:

```
session.headers.update(HEADERS)
```

### Authenticating

__Obtain a valid Facebook token before authenticating with the Tinder API!__

```
login = session.post(TINDER_HOST + '/auth', data=json.dumps({"facebook_token": facebook_token}))
session.headers.update({"X-Auth-Token": login['token']})
```

Parameter info:

<table>
  <tbody>
  <tr>
    <td>facebook_token</td>
    <td>**string**: Facebook token from the OAuth dialog</td>
  </tr>
  </tbody>
</table>

The easiest way to get this is to go <a href="https://www.facebook.com/dialog/oauth?client_id=464891386855067&redirect_uri=https://www.facebook.com/connect/login_success.html&scope=basic_info,email,public_profile,user_about_me,user_activities,user_birthday,user_education_history,user_friends,user_interests,user_likes,user_location,user_photos,user_relationship_details&response_type=token">here</a>, log in and then pick the auth token out of the URL you are redirected to.

Response:
```json
{
	"token": "XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXXX",
	"user": { ... },
	"globals": { ... },
	"versions": { ... }
}
```

### Updating your profile
```
profile = session.post(TINDER_HOST + '/profile', data=json.dumps({"discoverable" : discoverable, "age_filter_min" : age_min, "age_filter_max" : age_max, "gender": gender, "gender_filter" : gender_filter, "distance_filter" : distance, "bio": bio}))
```

Parameter info:

<table>
  <tbody>
  <tr>
    <td>discoverable</td>
    <td>**true**:Other users can swipe on you<br>**false**: nobody can see you except for your matches</td>
  </tr>
    <tr>
      <td>gender</td>
      <td>**0**: I'm a male<br>
      **1**: I'm a female</td>
    </tr>
    <tr>
      <td>age_filter_min</td>
      <td>**integer**: minimum age recommendations</td>
    </tr>
    <tr>
      <td>age_filter_max</td>
      <td>**integer**: maximum age recommendations</td>
    </tr>
    <tr>
    	<td>distance_filter</td>
    	<td>**integer**: search distance in miles (0 - 160 km)</td>
    </tr>
  </tbody>
</table>

Response:

```json
{
  TODO
	"token": "XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXXX",
	"user": { ... },
	"globals": { ... },
	"versions": { ... }
}
```

### Updating your school or work places
```
profile_school = session.put(TINDER_HOST + '/profile/school', data=json.dumps({"schools": [{"id": fb_school1_id}, {"id": fb_school2_id}], {...}}))

profile_jobs = session.put(TINDER_HOST + '/profile/job', data=json.dumps({"jobs": [{"company": [{"id": fb_job1_id}]}, {"company": [{"id": fb_job2_id}]}], {...}}))
```

Parameter info:

<table>
  <tbody>
  <tr>
    <td>schools</td>
    <td>**list**: List all your schools by using the fb_school_id, which need to be obtained from the Facebook Graph API.</td>
  </tr>
    <tr>
      <td>fb_school_id</td>
      <td>**string**: A FB id which represents the school</td>
    </tr>
  </tbody>
</table>

<table>
  <tbody>
  <tr>
    <td>jobs</td>
    <td>**list**: List all your jobs by using the fb_job_id, which need to be obtained from the Facebook Graph API.</td>
  </tr>
    <tr>
      <td>fb_job_id</td>
      <td>**string**: A FB id which represents the job</td>
    </tr>
  </tbody>
</table>

### Removing your school or work places
```
profile_school = session.delete(TINDER_HOST + '/profile/school')

profile_jobs = session.delete(TINDER_HOST + '/profile/job')
```

### Create, update and remove an username

Create a username so you will show up on the Tinder webprofiles and share your profile on social media.

```
create_username = session.post(TINDER_HOST + '/profile/username', data=json.dumps({"username": username}))
```

```
update_username = session.put(TINDER_HOST + '/profile/username', data=json.dumps({"username": username}))
```

```
remove_username = session.delete(TINDER_HOST + '/profile/username')
```

Parameter info:

<table>
  <tbody>
  <tr>
    <td>username</td>
    <td>**string**: Username of your choice</td>
  </tr>
  </tbody>
</table>

In case that the username is already taken, the user already registered one, ... then an error is returned:
```json
{
	"error":"User has already registered a username"
}

{
  "error":"User has no username to update"
}

{
  "error":"User has no username to remove"
}
```

### Create share link for social media
```
share_link = session.post(TINDER_HOST + '/user/{user_id}/share')
```

Parameter info:

<table>
  <tbody>
  <tr>
    <td>user_id</td>
    <td>**string**: Tinder user ID</td>
  </tr>
  </tbody>
</table>

### Meta data
When polling this endpoint I received a 404 HTTP ERROR but the official client still this use this.

```
meta_data = session.get(TINDER_HOST + '/meta')
```


### Reporting users
```
report = session.post(TINDER_HOST + '/report/{user_id}', data=json.dumps({"cause": cause}))
```

Parameter info:

<table>
  <tbody>
  <tr>
    <td>match_id</td>
    <td>**string**: Tinder match ID</td>
  </tr>
  <tr>
    <td>cause</td>
    <td>**1**: Reason is SPAM<br>
    **2**: Reason is inappropriate/offensive</td></td>
  </tr>
  </tbody>
</table>

### Upload local pictures to the Tinder image server
Also broken, a HTTP ERROR 500 is received but the offcial client works this way:

```
local_upload = session.post('https://imageupload.gotinder.com/image?client_photo_id=ProfilePhoto' + str(int(time.time())*1000), json={'userId': userID}, files={'file': open('test.jpeg', 'rb')})
```

### Upload facebook pictures to the Tinder image server
Select a Facebook photo to set it as a profile picture.

```
upload_fb = session.post(TINDER_HOST + '/media', data=json.dumps({"transmit": "fb", "assets": [{"ydistance_percent": ydistance_percent,"id": fb_picture_id,"xoffset_percent": xoffset_percent,"yoffset_percent": yoffset_percent,"xdistance_percent": xdistance_percent}]}))
```

Parameter info:

<table>
  <tbody>
  <tr>
    <td>ydistance_percent</td>
    <td>**int**: ???, 0 seems to work</td>
  </tr>
  <tr>
    <td>xdistance_percent</td>
    <td>**int**: ???, 0 seems to work</td>
  </tr>
  <tr>
    <td>yoffset_percent</td>
    <td>**int**: ???, 0 seems to work</td>
  </tr>
  <tr>
    <td>xoffset_percent</td>
    <td>**int**: ???, 0 seems to work</td>
  </tr>
  <tr>
    <td>id</td>
    <td>**string**: Facebook id of the picture</td>
  </tr>
  </tbody>
</table>

### Remove picture
```
remove_picture = session.delete(TINDER_HOST + '/media', data=json.dumps({"assets": [tinder_picture_id]}))
```

Parameter info:

<table>
  <tbody>
  <tr>
    <td>assets</td>
    <td>**list**: list of the pictures you want to delete with their Tinder picture id as strings.</td>
  </tr>
  </tbody>
</table>

Response:

```json
{
	"A list of all the pictures after the operation."
}
```

### Sending messages/gifs

Send a message to a match. Note you'll get a HTTP 500 back if you try to send a message to someone who isn't a match!

```
send_message = session.post(TINDER_HOST + '/user/matches/{match_id}', data=json.dumps({"message": message}))
```

Parameter info:

<table>
  <tbody>
  <tr>
    <td>match_id</td>
    <td>**string**: Tinder match ID</td>
  </tr>
  <tr>
    <td>message</td>
    <td>**string**: Message to send</td></td>
  </tr>
  </tbody>
</table>

Response:

```json
{
	"_id":"53467235483cb56c475cc1d6",
	"from":"53430689ab3c04c13e006ffb",
	"to":"533a59ea52046fc077002815",
	"match_id":"53464b0728ac73976d0a3fbf",
	"sent_date":"2014-04-10T10:28:05.764Z",
	"message":"hi!",
	"created_date":"2014-04-10T10:28:05.764Z"
}
```

```
send_gif = session.post(TINDER_HOST + '/user/matches/{match_id}', data=json.dumps({"type": "GIF", "message": message, "gif_id": gif_id}))
```

Parameter info:

<table>
  <tbody>
  <tr>
    <td>match_id</td>
    <td>**string**: Tinder match ID</td>
  </tr>
  <tr>
    <td>message</td>
    <td>**string**: The GIPHY URL of the GIF</td></td>
  </tr>
  <tr>
    <td>gif_id</td>
    <td>**string**: The GIPHY ID of the GIF</td></td>
  </tr>
  </tbody>
</table>

Response:

```json
{
	"_id":"53467235483cb56c475cc1d6",
	"from":"53430689ab3c04c13e006ffb",
	"to":"533a59ea52046fc077002815",
	"match_id":"53464b0728ac73976d0a3fbf",
	"sent_date":"2014-04-10T10:28:05.764Z",
	"message":"hi!",
	"created_date":"2014-04-10T10:28:05.764Z"
}
```

### Liking messages

Liking a message is like a superlike for messages.

```
like_message = session.post(TINDER_HOST + '/message/{message_id}/like')
unlike_message = session.delete(TINDER_HOST + '/message/{message_id}/like')
```

Parameter info:

<table>
  <tbody>
  <tr>
    <td>message_id</td>
    <td>**string**: Tinder ID of the message you want to like.</td>
  </tr>
  </tbody>
</table>

### Unmatch a match

Unmatch a match by sending an HTTP DELETE

```
unmatch = session.delete(TINDER_HOST + '/user/matches/{match_id}')
```

Parameter info:

<table>
  <tbody>
  <tr>
    <td>user_id</td>
    <td>**string**: Tinder match ID</td>
  </tr>
  </tbody>
</table>

Response:

```json
{
	"_id":"53467235483cb56c475cc1d6",
	"from":"53430689ab3c04c13e006ffb",
	"to":"533a59ea52046fc077002815",
	"match_id":"53464b0728ac73976d0a3fbf",
	"sent_date":"2014-04-10T10:28:05.764Z",
	"message":"hi!",
	"created_date":"2014-04-10T10:28:05.764Z"
}
```

### Updating your location

```
location = session.post(TINDER_HOST + '/user/ping', data=json.dumps({"lat": latitude, "lon": longitude))
```

Parameter info:

<table>
  <tbody>
  <tr>
    <td>lat</td>
    <td>**int**: Latitude of your location in degrees</td>
  </tr>
  <tr>
    <td>long</td>
    <td>**int**: Longitude of your location in degrees</td></td>
  </tr>
  </tbody>
</table>

```json
{
	"status": 200,
	"error": "position change not significant"
}
```

If the change in location is too small, you get the above error.

### Tinder history & updates

Get a complete list of your matches, messages, ... from your account.
The official Tinder client does this once when it's started for the first time, after that it relies on the incremental updates which you can requests by using the 'last_activity_date' parameter.

```
updates = session.post(TINDER_HOST + '/updates', data=json.dumps({"last_activity_date:" : date_in_JS_notation})
```

Response:
```json
{
	"matches": [{
		"_id": "53464b0728ac73976d0a3fbf",
		"messages": [{
			"_id": "534651198ce6da797248c1a3",
			"match_id": "53464b0728ac73976d0a3fbf",
			"to": "53430689ab3c04c13e006ffb",
			"from": "533a59ea52046fc077002815",
			"message": "hi  .... how is it going?",
			"sent_date": "2014-04-10T08:06:49.800Z",
			"created_date": "2014-04-10T08:06:49.800Z",
			"timestamp": 1397117209800
		}, {
			"_id": "53466fd298b7278b72156523",
			"match_id": "53464b0728ac73976d0a3fbf",
			"to": "533a59ea52046fc077002815",
			"from": "53430689ab3c04c13e006ffb",
			"message": "Good thanks you? :)",
			"sent_date": "2014-04-10T10:17:54.379Z",
			"created_date": "2014-04-10T10:17:54.379Z",
			"timestamp": 1397125074379
		}],
		"last_activity_date": "2014-04-10T10:17:54.379Z"
	}],
	"blocks": [],
	"lists": [],
	"deleted_lists": [],
	"last_activity_date": "2014-04-10T10:17:54.379Z"
}
```

### Liking, disliking & superliking
```
like = session.post(TINDER_HOST + '/like/{user_id}')
dislike = session.post(TINDER_HOST + '/pass/{user_id}')
superlike = session.post(TINDER_HOST + '/like/{user_id}/superlike')
```

Parameter info:

<table>
  <tbody>
  <tr>
    <td>user_id</td>
    <td>**string**: Tinder user ID</td>
  </tr>
</table>

Response for like:

```json
{
  "match": "true or false"
}
```

Response for superlike:

```json
{
  "match": "true or false",
  "superlikes": {
    "remaining": "superlikes_remaining",
    "resets_at": "reset_date_time"
  }
}
```

If they also liked you then 'match' will be `true`.
This is not returned if you disliked an user.


### Recommendations

Get your recommendations in this area, default limit is 10 users/request.
```
like = session.post(TINDER_HOST + '/recs', data=json.dumps({"limit:" : 10})
```

Parameter info:

<table>
  <tbody>
  <tr>
    <td>limit</td>
    <td>**int**: Number of Tinder users to like/dislike/superlike in this area. Default is 10, when done you need to run this request again.</td>
  </tr>
</table>

```json
{
    "status": 200,
    "results": [{
        "distance_mi": 2,
        "common_like_count": 0,
        "common_friend_count": 0,
        "common_likes": [],
        "common_friends": [],
        "_id": "518d666a2a00df0e490000b9",
        "bio": "",
        "birth_date": "1986-05-17T00:00:00.000Z",
        "gender": 1,
        "name": "Elen",
        "ping_time": "2014-04-08T11:59:18.494Z",
        "photos": [{
            "id": "fea4f480-7ce0-4143-a310-a03c2b2cdbc6",
            "main": true,
            "crop": "source",
            "fileName": "fea4f480-7ce0-4143-a310-a03c2b2cdbc6.jpg",
            "extension": "jpg",
            "processedFiles": [{
                "width": 640,
                "height": 640,
                "url": "http://images.gotinder.com/518d666a2a00df0e490000b9/640x640_fea4f480-7ce0-4143-a310-a03c2b2cdbc6.jpg"
            }, {
                "width": 320,
                "height": 320,
                "url": "http://images.gotinder.com/518d666a2a00df0e490000b9/320x320_fea4f480-7ce0-4143-a310-a03c2b2cdbc6.jpg"
            }, {
                "width": 172,
                "height": 172,
                "url": "http://images.gotinder.com/518d666a2a00df0e490000b9/172x172_fea4f480-7ce0-4143-a310-a03c2b2cdbc6.jpg"
            }, {
                "width": 84,
                "height": 84,
                "url": "http://images.gotinder.com/518d666a2a00df0e490000b9/84x84_fea4f480-7ce0-4143-a310-a03c2b2cdbc6.jpg"
            }],
            "url": "http://images.gotinder.com/518d666a2a00df0e490000b9/fea4f480-7ce0-4143-a310-a03c2b2cdbc6.jpg"
        }, {
            "url": "http://images.gotinder.com/518d666a2a00df0e490000b9/5c1d3231-5a75-4a07-91ff-5c012716583f.jpg",
            "processedFiles": [{
                "url": "http://images.gotinder.com/518d666a2a00df0e490000b9/640x640_pct_0_29.5312464_540_540_5c1d3231-5a75-4a07-91ff-5c012716583f.jpg",
                "height": 640,
                "width": 640
            }, {
                "url": "http://images.gotinder.com/518d666a2a00df0e490000b9/320x320_pct_0_29.5312464_540_540_5c1d3231-5a75-4a07-91ff-5c012716583f.jpg",
                "height": 320,
                "width": 320
            }, {
                "url": "http://images.gotinder.com/518d666a2a00df0e490000b9/172x172_pct_0_29.5312464_540_540_5c1d3231-5a75-4a07-91ff-5c012716583f.jpg",
                "height": 172,
                "width": 172
            }, {
                "url": "http://images.gotinder.com/518d666a2a00df0e490000b9/84x84_pct_0_29.5312464_540_540_5c1d3231-5a75-4a07-91ff-5c012716583f.jpg",
                "height": 84,
                "width": 84
            }],
            "extension": "jpg",
            "fileName": "5c1d3231-5a75-4a07-91ff-5c012716583f.jpg",
            "main": false,
            "ydistance_percent": 0.75,
            "yoffset_percent": 0.04101562,
            "xoffset_percent": 0,
            "id": "5c1d3231-5a75-4a07-91ff-5c012716583f",
            "xdistance_percent": 1
        }, {
            "url": "http://images.gotinder.com/518d666a2a00df0e490000b9/5abd87e5-a181-4946-a8b9-880926a78943.jpg",
            "processedFiles": [{
                "url": "http://images.gotinder.com/518d666a2a00df0e490000b9/640x640_pct_0_118.125_540_540_5abd87e5-a181-4946-a8b9-880926a78943.jpg",
                "height": 640,
                "width": 640
            }, {
                "url": "http://images.gotinder.com/518d666a2a00df0e490000b9/320x320_pct_0_118.125_540_540_5abd87e5-a181-4946-a8b9-880926a78943.jpg",
                "height": 320,
                "width": 320
            }, {
                "url": "http://images.gotinder.com/518d666a2a00df0e490000b9/172x172_pct_0_118.125_540_540_5abd87e5-a181-4946-a8b9-880926a78943.jpg",
                "height": 172,
                "width": 172
            }, {
                "url": "http://images.gotinder.com/518d666a2a00df0e490000b9/84x84_pct_0_118.125_540_540_5abd87e5-a181-4946-a8b9-880926a78943.jpg",
                "height": 84,
                "width": 84
            }],
            "extension": "jpg",
            "fileName": "5abd87e5-a181-4946-a8b9-880926a78943.jpg",
            "main": false,
            "ydistance_percent": 0.75,
            "yoffset_percent": 0.1640625,
            "xoffset_percent": 0,
            "id": "5abd87e5-a181-4946-a8b9-880926a78943",
            "xdistance_percent": 1
        }, {
            "url": "http://images.gotinder.com/518d666a2a00df0e490000b9/5e168698-a034-40c0-b7fb-7c05743f2310.jpg",
            "processedFiles": [{
                "url": "http://images.gotinder.com/518d666a2a00df0e490000b9/640x640_pct_157.570344_0_405_405_5e168698-a034-40c0-b7fb-7c05743f2310.jpg",
                "height": 640,
                "width": 640
            }, {
                "url": "http://images.gotinder.com/518d666a2a00df0e490000b9/320x320_pct_157.570344_0_405_405_5e168698-a034-40c0-b7fb-7c05743f2310.jpg",
                "height": 320,
                "width": 320
            }, {
                "url": "http://images.gotinder.com/518d666a2a00df0e490000b9/172x172_pct_157.570344_0_405_405_5e168698-a034-40c0-b7fb-7c05743f2310.jpg",
                "height": 172,
                "width": 172
            }, {
                "url": "http://images.gotinder.com/518d666a2a00df0e490000b9/84x84_pct_157.570344_0_405_405_5e168698-a034-40c0-b7fb-7c05743f2310.jpg",
                "height": 84,
                "width": 84
            }],
            "extension": "jpg",
            "fileName": "5e168698-a034-40c0-b7fb-7c05743f2310.jpg",
            "main": false,
            "ydistance_percent": 1,
            "yoffset_percent": 0,
            "xoffset_percent": 0.2188477,
            "id": "5e168698-a034-40c0-b7fb-7c05743f2310",
            "xdistance_percent": 0.5625
        }],
        "birth_date_info": "fuzzy birthdate active, not displaying real birth_date"
    }, {
        "distance_mi": 4,
        "common_like_count": 0,
        "common_friend_count": 0,
        "common_likes": [],
        "common_friends": [],
        "_id": "52cfc097f43cd91a67003639",
        "bio": "",
        "birth_date": "1987-11-02T00:00:00.000Z",
        "gender": 1,
        "name": "Cristina",
        "ping_time": "2014-04-06T16:52:51.605Z",
        "photos": [{
            "id": "4ab7173f-7884-4fe3-872f-32c01d77de2a",
            "main": "main",
            "shape": "center_square",
            "fileName": "4ab7173f-7884-4fe3-872f-32c01d77de2a.jpg",
            "extension": "jpg",
            "processedFiles": [{
                "width": 640,
                "height": 640,
                "url": "http://images.gotinder.com/52cfc097f43cd91a67003639/640x640_4ab7173f-7884-4fe3-872f-32c01d77de2a.jpg"
            }, {
                "width": 320,
                "height": 320,
                "url": "http://images.gotinder.com/52cfc097f43cd91a67003639/320x320_4ab7173f-7884-4fe3-872f-32c01d77de2a.jpg"
            }, {
                "width": 172,
                "height": 172,
                "url": "http://images.gotinder.com/52cfc097f43cd91a67003639/172x172_4ab7173f-7884-4fe3-872f-32c01d77de2a.jpg"
            }, {
                "width": 84,
                "height": 84,
                "url": "http://images.gotinder.com/52cfc097f43cd91a67003639/84x84_4ab7173f-7884-4fe3-872f-32c01d77de2a.jpg"
            }],
            "url": "http://images.gotinder.com/52cfc097f43cd91a67003639/4ab7173f-7884-4fe3-872f-32c01d77de2a.jpg"
        }, {
            "id": "bb8ac90b-f48a-4a1c-8cba-0c05d26f1b47",
            "shape": "center_square",
            "fileName": "bb8ac90b-f48a-4a1c-8cba-0c05d26f1b47.jpg",
            "extension": "jpg",
            "processedFiles": [{
                "width": 640,
                "height": 640,
                "url": "http://images.gotinder.com/52cfc097f43cd91a67003639/640x640_bb8ac90b-f48a-4a1c-8cba-0c05d26f1b47.jpg"
            }, {
                "width": 320,
                "height": 320,
                "url": "http://images.gotinder.com/52cfc097f43cd91a67003639/320x320_bb8ac90b-f48a-4a1c-8cba-0c05d26f1b47.jpg"
            }, {
                "width": 172,
                "height": 172,
                "url": "http://images.gotinder.com/52cfc097f43cd91a67003639/172x172_bb8ac90b-f48a-4a1c-8cba-0c05d26f1b47.jpg"
            }, {
                "width": 84,
                "height": 84,
                "url": "http://images.gotinder.com/52cfc097f43cd91a67003639/84x84_bb8ac90b-f48a-4a1c-8cba-0c05d26f1b47.jpg"
            }],
            "url": "http://images.gotinder.com/52cfc097f43cd91a67003639/bb8ac90b-f48a-4a1c-8cba-0c05d26f1b47.jpg"
        }, {
            "id": "dabe1c27-f186-48f2-807f-8a68e3831fe9",
            "shape": "center_square",
            "fileName": "dabe1c27-f186-48f2-807f-8a68e3831fe9.jpg",
            "extension": "jpg",
            "processedFiles": [{
                "width": 640,
                "height": 640,
                "url": "http://images.gotinder.com/52cfc097f43cd91a67003639/640x640_dabe1c27-f186-48f2-807f-8a68e3831fe9.jpg"
            }, {
                "width": 320,
                "height": 320,
                "url": "http://images.gotinder.com/52cfc097f43cd91a67003639/320x320_dabe1c27-f186-48f2-807f-8a68e3831fe9.jpg"
            }, {
                "width": 172,
                "height": 172,
                "url": "http://images.gotinder.com/52cfc097f43cd91a67003639/172x172_dabe1c27-f186-48f2-807f-8a68e3831fe9.jpg"
            }, {
                "width": 84,
                "height": 84,
                "url": "http://images.gotinder.com/52cfc097f43cd91a67003639/84x84_dabe1c27-f186-48f2-807f-8a68e3831fe9.jpg"
            }],
            "url": "http://images.gotinder.com/52cfc097f43cd91a67003639/dabe1c27-f186-48f2-807f-8a68e3831fe9.jpg"
        }, {
            "url": "http://images.gotinder.com/52cfc097f43cd91a67003639/59263e9d-6d76-4f42-8c8e-b4cf635b03c7.jpg",
            "processedFiles": [{
                "url": "http://images.gotinder.com/52cfc097f43cd91a67003639/640x640_59263e9d-6d76-4f42-8c8e-b4cf635b03c7.jpg",
                "height": 640,
                "width": 640
            }, {
                "url": "http://images.gotinder.com/52cfc097f43cd91a67003639/320x320_59263e9d-6d76-4f42-8c8e-b4cf635b03c7.jpg",
                "height": 320,
                "width": 320
            }, {
                "url": "http://images.gotinder.com/52cfc097f43cd91a67003639/172x172_59263e9d-6d76-4f42-8c8e-b4cf635b03c7.jpg",
                "height": 172,
                "width": 172
            }, {
                "url": "http://images.gotinder.com/52cfc097f43cd91a67003639/84x84_59263e9d-6d76-4f42-8c8e-b4cf635b03c7.jpg",
                "height": 84,
                "width": 84
            }],
            "extension": "jpg",
            "fileName": "59263e9d-6d76-4f42-8c8e-b4cf635b03c7.jpg",
            "main": false,
            "ydistance_percent": 0.75,
            "yoffset_percent": 0.08554687,
            "xoffset_percent": 0,
            "id": "59263e9d-6d76-4f42-8c8e-b4cf635b03c7",
            "xdistance_percent": 1
        }],
        "birth_date_info": "fuzzy birthdate active, not displaying real birth_date"
    }, "JSON DATA OF NEXT USER" ]
}
```

### Delete account
Delete your account, this can not be undone!

```
delete_account = session.delete(TINDER_HOST + '/profile')
```
