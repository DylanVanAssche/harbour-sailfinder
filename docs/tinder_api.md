# Tinder API
 _with Python Requests_

Inspired by <a href="https://gist.github.com/rtt/10403467">this</a> Github Gist.
Currently several new API endpoints are available but they aren't described here yet.
For example:
- Direct image upload
- Facebook image upload
- Spotify integration
- Instagram integration
- Update schools & jobs

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
    <td>__string__: Facebook token from the OAuth dialog</td>
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
    <td>__true__:Other users can swipe on you<br>__false__: nobody can see you except for your matches</td>
  </tr>
    <tr>
      <td>gender</td>
      <td>__0__: I'm a male<br>
      __1__: I'm a female</td>
    </tr>
    <tr>
      <td>age_filter_min</td>
      <td>__integer__: minimum age recommendations</td>
    </tr>
    <tr>
      <td>age_filter_max</td>
      <td>__integer__: maximum age recommendations</td>
    </tr>
    <tr>
    	<td>distance_filter</td>
    	<td>__integer__: search distance in miles (0 - 160 km)</td>
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

### Meta data

Request the current app meta data like number of superlikes, can like and app tutorials.
The HTTP request type matters a lot, otherwise you get an error.

```python
meta = session.get(TINDER_HOST + '/meta')
```

Response:
```json
{
  "client_resources": {...},
  "globals": {...},
  "travel": {...},
  "groups": {...},
  "products": {...},
  "notifications": {...},
  "purchases": [],
  "rating": {...},
  "status": {...},
  "tutorials": {...},
	"user": { ... },
	"versions": { ... }
}
```

Updates interval is also listed in the meta data. This defines how fast you may poll the /updates endpoint for incremental updates (no full history update).

### Reporting a user
```python
report = session.post(TINDER_HOST + '/report/{user_id}', data=json.dumps({"cause": cause}))
```

Parameter info:

<table>
  <tbody>
  <tr>
    <td>id</td>
    <td>__string__: Tinder user ID</td>
  </tr>
  <tr>
    <td>cause</td>
    <td>__1__: Reason is SPAM<br>
    __2__: Reason is inappropriate/offensive</td></td>
  </tr>
  </tbody>
</table>


### Send message

Send a message to a match. Note you'll get a HTTP 500 back if you try to send a message to someone who isn't a match!

```python
send_message = session.post(TINDER_HOST + '/user/matches/{match_id}', data=json.dumps({"message": message}))
```

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

### Like/Unlike message

Like or unlike a message from a match, unliking only possible when the message has been liked by you in the past.

```python
like_message = session.post(TINDER_HOST + '/message/{message_id}/like')
unlike_message = session.delete(TINDER_HOST + '/message/{message_id}/like')
```

Response:
```
A 201 or 204 HTTP response, no JSON content is returned.
```

### Updating your location
```python
location = session.post(TINDER_HOST + '/user/ping', data=json.dumps({"lat": latitude, "lon": longitude}))
```

```json
{
	"status": 200,
	"error": "position change not significant"
}
```

### Get updates

Updates contain several things such as:
- Matches + messages
- Unmatched users
- Liked messages

The incremental updates (with a supplied ISO string date) are used to check for notifications, update local databases, ...

```python
updates = session.post(TINDER_HOST + '/updates', data=json.dumps({"last_activity_date": date}))
```

Parameter info:

<table>
  <tbody>
  <tr>
    <td>date</td>
    <td>__string__: Empty will return the whole account history, when an ISO string date is supplied only the updates from that date are returned</td>
  </tr>
  </tbody>
</table>

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

### Get information about an user

Returns all the information known about an user based on their user_id.
The HTTP request type matters a lot, otherwise you get an error.

```python
about = session.get(TINDER_HOST + '/user/{user_id}')
```

Response:
```
The same as when you request /recs and look at the recommendation it's JSON.
```

### Unmatch

Unmatching based on the match_id, the other user will receive the match_id through /updates in "blocks" to let the client know that they unmatched.

```python
unmatch = session.delete(TINDER_HOST + '/user/matches/{match_id}')
```

Response:
```
A 202 or 204 HTTP response, no JSON content is returned.
```

### To 'like', 'pass' or superlike a User
```python
> curl https://api.gotinder.com/{like|pass}/{_id}
like = session.get(TINDER_HOST + '/like/{user_id}')
superlike = session.post(TINDER_HOST + '/like/{user_id}' + '/super')
pass = session.get(TINDER_HOST + '/pass/{user_id}')
```

Response:
```json
{match: match_result}
```

`match_result` will be `true` if they like you, `false` if they haven't liked you or don't like you


### Recommendations
```python
like = session.post(TINDER_HOST + '/recs', , data=json.dumps({"limit": limit})
```

Parameter info:

<table>
  <tbody>
  <tr>
    <td>limit</td>
    <td>__integer__: 10 seems to be the normal limit</td>
  </tr>
  </tbody>
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
    }, ... ]
}
```
