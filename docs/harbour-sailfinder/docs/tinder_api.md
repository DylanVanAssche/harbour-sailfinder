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

*'api.gotinder.com' will be referred in this document as TINDER_HOST*

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
    <td>**string**: Facebook token from the OAuth dialog, valid for 60 days</td>
  </tr>
  </tbody>
</table>

Since Augustus 2016, the login url of Tinder changed, the new url can be found <a href="https://www.facebook.com/v2.6/dialog/oauth?redirect_uri=fb464891386855067%3A%2F%2Fauthorize%2F&display=touch&state=%7B%22challenge%22%3A%22IUUkEUqIGud332lfu%252BMJhxL4Wlc%253D%22%2C%220_auth_logger_id%22%3A%2230F06532-A1B9-4B10-BB28-B29956C71AB1%22%2C%22com.facebook.sdk_client_state%22%3Atrue%2C%223_method%22%3A%22sfvc_auth%22%7D&scope=user_birthday%2Cuser_photos%2Cuser_education_history%2Cemail%2Cuser_relationship_details%2Cuser_friends%2Cuser_work_history%2Cuser_likes&response_type=token%2Csigned_request&default_audience=friends&return_scopes=true&auth_type=rerequest&client_id=464891386855067&ret=login&sdk=ios&logger_id=30F06532-A1B9-4B10-BB28-B29956C71AB1&ext=1470840777&hash=AeZqkIcf-NEW6vBd">here</a>, check in the developer console of your browser for the token, or use Robobrowser to create an automated version of the login.

Note: You can view best this link with the following browser agent:

```
Mozilla/5.0 (Linux; U; en-gb; KFTHWI Build/JDQ39) AppleWebKit/535.19 (KHTML, like Gecko) Silk/3.16 Safari/535.19
```

Response:
```json
{
    "token": "XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX",
    "globals": {
        "moments_interval": 30000,
        "boost_down": 8,
        "boost_up": 7,
        "updates_interval": 2000,
        "sparks": false,
        "share_default_text": "<style>body{color:#fff;text-align:center;font-family:HelveticaNeue;text-shadow:0 1px 1px rgba(0,0,0,0.63);}h1{font-size:24px;line-height:24px;margin:0;}p{font-size:16px;margin:8px;}</style><h1>Get a Boost</h1><p><strong>Invite friends</strong> to show up <br/><strong>even higher</strong> in recommendations.</p>",
        "recs_size": 40,
        "fetch_connections": true,
        "invite_type": "client",
        "matchmaker_default_message": "I want you to meet someone. I introduced you on Tinder www.gotinder.com/app",
        "sparks_enabled": false,
        "mqtt": false,
        "kontagent_enabled": false,
        "boost_decay": 180,
        "recs_interval": 20000,
        "plus": true,
        "friends": true,
        "kontagent": false,
        "tinder_sparks": true
    },
    "user": {
        "active_time": "2017-01-07T14:39:01.234Z",
        "create_date": "2016-05-30T13:49:45.435Z",
        "purchases": [],
        "age_filter_min": 18,
        "discoverable": false,
        "full_name": "Your full name",
        "api_token": "XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX",
        "is_new_user": false,
        "connection_count": 1,
        "squads_discoverable": true,
        "interests": [],
        "bio": "",
        "jobs": [
            {
                "company": {
                    "displayed": true,
                    "id": "FB_ID of company",
                    "name": "Self-Employed"
                },
                "title": {
                    "displayed": true,
                    "id": "FB_ID of title",
                    "name": "Chief Executive Officer"
                }
            }
        ],
        "distance_filter": 99,
        "can_create_squad": true,
        "gender_filter": 0,
        "photos": [
            {
                "extension": "jpg",
                "url": "http://images.gotinder.com/user_id/picture_id.jpg",
                "fbId": "directupload",
                "fileName": "picture_id.jpg",
                "id": "picture_id",
                "processedFiles": [
                    {
                        "url": "http://images.gotinder.com/user_id/640x640_picture_id.jpg",
                        "width": 640,
                        "height": 640
                    },
                    {
                        "url": "http://images.gotinder.com/user_id/320x320_picture_id.jpg",
                        "width": 320,
                        "height": 320
                    },
                    {
                        "url": "http://images.gotinder.com/user_id/172x172_picture_id.jpg",
                        "width": 172,
                        "height": 172
                    },
                    {
                        "url": "http://images.gotinder.com/user_id/84x84_picture_id.jpg",
                        "width": 84,
                        "height": 84
                    }
                ]
            }
        ],
        "ping_time": "2017-01-07T12:16:51.460Z",
        "groups": [
            "plus_subscription_999"
        ],
        "schools": [],
        "name": "first_name",
        "squads_only": false,
        "gender": 1,
        "photos_processing": false,
        "age_filter_max": 1000,
        "birth_date": "full_birthday",
        "_id": "user_id"
    },
    "versions": {
        "age_filter": "2.1.0",
        "trending_active_text": "10.0.0",
        "active_text": "0.0.0",
        "trending": "10.0.0",
        "matchmaker": "2.1.0"
    }
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
    <td>**true**: Other users can swipe on you<br>**false**: nobody can see you except for your matches</td>
  </tr>
    <tr>
      <td>gender</td>
      <td>**0**: I'm a male<br>
      **1**: I'm a female</td>
    </tr>
    <tr>
      <td>gender_filter</td>
      <td>
      **-1**: show everyone<br>
      **0**: show males<br>
      **1**: show females
      </td>
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

**Note**: No data returns in a response without changing the account settings.

Response:

```json
{
    "_id":"user_id",
    "age_filter_max":1000,
    "age_filter_min":18,
    "badges":[],
    "bio":"",
    "birth_date":"1996-01-01T00:00:00.000Z",
    "blend":"optimal",
    "can_create_squad":true,
    "connection_count":0,
    "create_date":"2016-05-30T13:49:45.435Z",
    "discoverable":false,
    "distance_filter":99,
    "facebook_id":"135932223489915",
    "gender":1,
    "gender_filter":0,
    "interested_in":[
        0
    ],
    "interests":[],
    "jobs":[
        {
            "company":{
                "displayed":true,
                "id":"594445203920155",
                "name":"Self-Employed"
            },
            "title":{
                "displayed":true,
                "id":"103113219728224",
                "name":"Chief Executive Officer"
            }
        }
    ],
    "location":null,
    "name":"John",
    "photo_optimizer_has_result":false,
    "photos":[
        {
            "extension":"jpg",
            "fbId":"directupload",
            "fileName":"picture_id.jpg",
            "id":"picture_id",
            "processedFiles":[
                {
                    "height":640,
                    "url":"http://images.gotinder.com/user_id/640x640_picture_id.jpg",
                    "width":640
                },
                {
                    "height":320,
                    "url":"http://images.gotinder.com/user_id/320x320_picture_id.jpg",
                    "width":320
                },
                {
                    "height":172,
                    "url":"http://images.gotinder.com/user_id/172x172_picture_id.jpg",
                    "width":172
                },
                {
                    "height":84,
                    "url":"http://images.gotinder.com/user_id/84x84_picture_id.jpg",
                    "width":84
                }
            ],
            "url":"http://images.gotinder.com/user_id/picture_id.jpg"
        }
    ],
    "ping_time":"2017-01-09T19:22:42.194Z",
    "pos":{
        "at":1483989762488,
        "lat":48.8567,
        "lon":2.3508
    },
    "pos_info":{
        "city":{
            "bounds":{
                "ne":{
                    "lat":48.90164950000002,
                    "lng":2.416341999999929
                },
                "sw":{
                    "lat":48.815856999999994,
                    "lng":2.2237277313554387
                }
            },
            "name":"Paris"
        },
        "country":{
            "bounds":{
                "ne":{
                    "lat":51.089517,
                    "lng":10.125
                },
                "sw":{
                    "lat":41.310257,
                    "lng":-9
                }
            },
            "cc":"FR",
            "name":"France"
        }
    },
    "schools":[],
    "squad_ads_shown":true,
    "squads_discoverable":true,
    "squads_only":false
}
```

Note: the location used here is not a real one but set by the /user/ping endpoint to Paris, France.

### Updating your school or work places
```
profile_school = session.put(TINDER_HOST + '/profile/school', data=json.dumps({"schools": [{"id": fb_school1_id}, {"id": fb_school2_id}], {...}}))

profile_jobs = session.put(TINDER_HOST + '/profile/job', data=json.dumps({"jobs": {"company": [{"id": fb_job1_id}]}}))
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
    <td>**string**: Your current jobs by using the fb_job_id, which need to be obtained from the Facebook Graph API.</td>
  </tr>
    <tr>
      <td>fb_job_id</td>
      <td>**list**: A FB id which represents the job and several other things about this job. TODO</td>
    </tr>
  </tbody>
</table>

Note: The response is the same as with the endpoint /profile.


### Spotify
Pick your favourite song and add it to your profile.
TO DO
```
```

### Instagram
Connect your Instragram account and add it to your profile.
TO DO
```
```

### Removing your school or work places
```
profile_school = session.delete(TINDER_HOST + '/profile/school')

profile_jobs = session.delete(TINDER_HOST + '/profile/job')
```

Note: The response is the same as with the endpoint /profile.


### Create, update and remove an username
**DEPRECATED!**

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

Note: The response is the same as with the endpoint /profile.


### Create share link for social media
**DEPRACTED!**

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
HTTP POST on this endpoint returns a 404 HTTP ERROR in HTML. HTTP GET IS OK

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
    <td>
    **0**: other<br>
    **1**: SPAM<br>
    **2**: inappropriate messages<br>
    **4**: inappropriate pictures<br>
    **5**: bad offline behavior
    </td></td>
  </tr>
  <tr>
    <td>text</td>
    <td>**string**: When cause=0, an explanation can be added to the report.</td>
  </tr>
  </tbody>
</table>

### Upload local pictures to the Tinder image server
Upload a picture to the Tinder image server.

```
local_upload = session.post('https://imageupload.gotinder.com/image?client_photo_id=ProfilePhoto' + str(int(time.time())*1000), json={'userId': userID}, files={'file': open('test.jpeg', 'rb')})
```

### Upload facebook pictures to the Tinder image server
Select a Facebook photo and upload it to the Tinder image server.

```
upload_fb = session.post(TINDER_HOST + '/media', data=json.dumps({"transmit": "fb", "assets": [{"ydistance_percent": ydistance_percent,"id": fb_picture_id,"xoffset_percent": xoffset_percent,"yoffset_percent": yoffset_percent,"xdistance_percent": xdistance_percent}]}))
```

Parameter info:

<table>
  <tbody>
  <tr>
    <td>xdistance_percent</td>
    <td>**int**: zoom percentage in X, 0 = full zoom, 1 = no zoom</td>
  </tr>
  <tr>
    <td>ydistance_percent</td>
    <td>**int**: zoom percentage in Y, 0 = full zoom, 1 = no zoom</td>
  </tr>
  <tr>
    <td>xoffset_percent</td>
    <td>**int**: offset from the left corner in percentage (0...1)</td>
  </tr>
  <tr>
    <td>yoffset_percent</td>
    <td>**int**: offset from the top corner in percentage (0...1)</td>
  </tr>
  <tr>
    <td>id</td>
    <td>**string**: Facebook id of the picture</td>
  </tr>
  </tbody>
</table>

### Remove picture
Remove the picture from the Tinder image server, in case that the picture uploaded was from Facebook, then it will still exist on Facebook after this request.
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

### Get info about a user

GET request! POST request will result a 404 HTTP received as HTML instead of JSON!

```
send_message = session.get(TINDER_HOST + '/user/{user_id}')
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

Response:

```json
{
    "results":{
        "_id":"user_id",
        "badges":[],
        "bio":"",
        "birth_date":"1986-01-11T20:35:47.650Z",
        "birth_date_info":"fuzzy birthdate active, not displaying real birth_date",
        "common_connections":[],
        "common_friends":[],
        "common_interests":[],
        "common_likes":[],
        "connection_count":0,
        "distance_mi":12,
        "gender":0,
        "jobs":[],
        "name":"full_name",
        "photos":[
            {
                "extension":"jpg",
                "fileName":"picture_id.jpg",
                "id":"picture_id",
                "processedFiles":[
                    {
                        "height":640,
                        "url":"http://images.gotinder.com/user_id/640x640_picture_id.jpg",
                        "width":640
                    },
                    {
                        "height":320,
                        "url":"http://images.gotinder.com/user_id/320x320_picture_id.jpg",
                        "width":320
                    },
                    {
                        "height":172,
                        "url":"http://images.gotinder.com/user_id/172x172_picture_id.jpg",
                        "width":172
                    },
                    {
                        "height":84,
                        "url":"http://images.gotinder.com/user_id/84x84_picture_id.jpg",
                        "width":84
                    }
                ],
                "url":"http://images.gotinder.com/user_id/picture_id.jpg",
                "xdistance_percent":1,
                "xoffset_percent":0,
                "ydistance_percent":0.6666666865348816,
                "yoffset_percent":0.05138888955116272
            },
            {
                "extension":"jpg",
                "fileName":"picture_id.jpg",
                "id":"picture_id",
                "processedFiles":[
                    {
                        "height":640,
                        "url":"http://images.gotinder.com/user_id/640x640_picture_id.jpg",
                        "width":640
                    },
                    {
                        "height":320,
                        "url":"http://images.gotinder.com/user_id/320x320_picture_id.jpg",
                        "width":320
                    },
                    {
                        "height":172,
                        "url":"http://images.gotinder.com/user_id/172x172_picture_id.jpg",
                        "width":172
                    },
                    {
                        "height":84,
                        "url":"http://images.gotinder.com/user_id/84x84_picture_id.jpg",
                        "width":84
                    }
                ],
                "url":"http://images.gotinder.com/user_id/picture_id.jpg",
                "xdistance_percent":1,
                "xoffset_percent":0,
                "ydistance_percent":0.75,
                "yoffset_percent":0.12222222238779068
            },
            {
                "extension":"jpg",
                "fileName":"picture_id.jpg",
                "id":"picture_id",
                "processedFiles":[
                    {
                        "height":640,
                        "url":"http://images.gotinder.com/user_id/640x640_picture_id.jpg",
                        "width":640
                    },
                    {
                        "height":320,
                        "url":"http://images.gotinder.com/user_id/320x320_picture_id.jpg",
                        "width":320
                    },
                    {
                        "height":172,
                        "url":"http://images.gotinder.com/user_id/172x172_picture_id.jpg",
                        "width":172
                    },
                    {
                        "height":84,
                        "url":"http://images.gotinder.com/user_id/84x84_picture_id.jpg",
                        "width":84
                    }
                ],
                "url":"http://images.gotinder.com/user_id/picture_id.jpg"
            },
            {
                "extension":"jpg",
                "fileName":"picture_id.jpg",
                "id":"picture_id",
                "processedFiles":[
                    {
                        "height":640,
                        "url":"http://images.gotinder.com/user_id/640x640_picture_id.jpg",
                        "width":640
                    },
                    {
                        "height":320,
                        "url":"http://images.gotinder.com/user_id/320x320_picture_id.jpg",
                        "width":320
                    },
                    {
                        "height":172,
                        "url":"http://images.gotinder.com/user_id/172x172_picture_id.jpg",
                        "width":172
                    },
                    {
                        "height":84,
                        "url":"http://images.gotinder.com/user_id/84x84_picture_id.jpg",
                        "width":84
                    }
                ],
                "url":"http://images.gotinder.com/user_id/picture_id.jpg"
            },
            {
                "extension":"jpg",
                "fileName":"picture_id.jpg",
                "id":"picture_id",
                "processedFiles":[
                    {
                        "height":640,
                        "url":"http://images.gotinder.com/user_id/640x640_picture_id.jpg",
                        "width":640
                    },
                    {
                        "height":320,
                        "url":"http://images.gotinder.com/user_id/320x320_picture_id.jpg",
                        "width":320
                    },
                    {
                        "height":172,
                        "url":"http://images.gotinder.com/user_id/172x172_picture_id.jpg",
                        "width":172
                    },
                    {
                        "height":84,
                        "url":"http://images.gotinder.com/user_id/84x84_picture_id.jpg",
                        "width":84
                    }
                ],
                "url":"http://images.gotinder.com/user_id/picture_id.jpg"
            },
            {
                "extension":"jpg",
                "fileName":"picture_id.jpg",
                "id":"picture_id",
                "processedFiles":[
                    {
                        "height":640,
                        "url":"http://images.gotinder.com/user_id/640x640_picture_id.jpg",
                        "width":640
                    },
                    {
                        "height":320,
                        "url":"http://images.gotinder.com/user_id/320x320_picture_id.jpg",
                        "width":320
                    },
                    {
                        "height":172,
                        "url":"http://images.gotinder.com/user_id/172x172_picture_id.jpg",
                        "width":172
                    },
                    {
                        "height":84,
                        "url":"http://images.gotinder.com/user_id/84x84_picture_id.jpg",
                        "width":84
                    }
                ],
                "url":"http://images.gotinder.com/user_id/picture_id.jpg"
            }
        ],
        "ping_time":"2017-01-08T18:02:01.953Z",
        "schools":[],
        "teasers":[],
        "uncommon_interests":[]
    },
    "status":200
}
```

### Sending messages/gifs

Send a message to a match. Note yo'll get a HTTP 500 back if you try to send a message to someone who isn't a match!

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
	"_id":"message_id",
	"from":"user_id_1",
	"to":"user_id_2",
	"match_id":"match_id",
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
    "likes_remaining":100,
    "match":false
}
```

```json
{
    "likes_remaining":100,
    "match":{
        "_id":"match_id",
        "closed":false,
        "common_friend_count":0,
        "common_like_count":0,
        "created_date":"2017-01-09T18:05:27.053Z",
        "dead":false,
        "following":true,
        "following_moments":true,
        "is_boost_match":false,
        "is_super_like":false,
        "last_activity_date":"2017-01-09T18:05:27.053Z",
        "message_count":0,
        "messages":[],
        "participants":[
            "my_user_id",
            "other_person_user_id"
        ],
        "pending":false
    }
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
            "is_traveling": false,
            "common_likes": [],
            "common_connections": [],
            "teasers": [
                {
                    "type": "school",
                    "string": "school_name"
                }
            ],
            "common_friends": [],
            "content_hash": "wnqHrqtZwC2nT3wuR3SMJH22UYLtdXt5DC1sl4SddcwRux0",
            "connection_count": 0,
            "badges": [],
            "distance_mi": 6,
            "hide_age": false,
            "bio": "The user his/her bio",
            "jobs": [],
            "birth_date_info": "fuzzy birthdate active, not displaying real birth_date",
            "photos": [
                {
                    "url": "http://images.gotinder.com/564f90f0df583cc63b873e60/picture_id.jpg",
                    "id": "picture_id",
                    "processedFiles": [
                        {
                            "url": "http://images.gotinder.com/564f90f0df583cc63b873e60/640x640_picture_id.jpg",
                            "width": 640,
                            "height": 640
                        },
                        {
                            "url": "http://images.gotinder.com/564f90f0df583cc63b873e60/320x320_picture_id.jpg",
                            "width": 320,
                            "height": 320
                        },
                        {
                            "url": "http://images.gotinder.com/564f90f0df583cc63b873e60/172x172_picture_id.jpg",
                            "width": 172,
                            "height": 172
                        },
                        {
                            "url": "http://images.gotinder.com/564f90f0df583cc63b873e60/84x84_picture_id.jpg",
                            "width": 84,
                            "height": 84
                        }
                    ]
                },
                {
                    "url": "http://images.gotinder.com/564f90f0df583cc63b873e60/picture_id.jpg",
                    "id": "picture_id",
                    "processedFiles": [
                        {
                            "url": "http://images.gotinder.com/564f90f0df583cc63b873e60/640x640_picture_id.jpg",
                            "width": 640,
                            "height": 640
                        },
                        {
                            "url": "http://images.gotinder.com/564f90f0df583cc63b873e60/320x320_picture_id.jpg",
                            "width": 320,
                            "height": 320
                        },
                        {
                            "url": "http://images.gotinder.com/564f90f0df583cc63b873e60/172x172_picture_id.jpg",
                            "width": 172,
                            "height": 172
                        },
                        {
                            "url": "http://images.gotinder.com/564f90f0df583cc63b873e60/84x84_picture_id.jpg",
                            "width": 84,
                            "height": 84
                        }
                    ]
                },
                {
                    "url": "http://images.gotinder.com/564f90f0df583cc63b873e60/picture_id.jpg",
                    "id": "picture_id",
                    "processedFiles": [
                        {
                            "url": "http://images.gotinder.com/564f90f0df583cc63b873e60/640x640_picture_id.jpg",
                            "width": 640,
                            "height": 640
                        },
                        {
                            "url": "http://images.gotinder.com/564f90f0df583cc63b873e60/320x320_picture_id.jpg",
                            "width": 320,
                            "height": 320
                        },
                        {
                            "url": "http://images.gotinder.com/564f90f0df583cc63b873e60/172x172_picture_id.jpg",
                            "width": 172,
                            "height": 172
                        },
                        {
                            "url": "http://images.gotinder.com/564f90f0df583cc63b873e60/84x84_picture_id.jpg",
                            "width": 84,
                            "height": 84
                        }
                    ]
                },
                {
                    "url": "http://images.gotinder.com/564f90f0df583cc63b873e60/picture_id.jpg",
                    "id": "picture_id",
                    "processedFiles": [
                        {
                            "url": "http://images.gotinder.com/564f90f0df583cc63b873e60/640x640_picture_id.jpg",
                            "width": 640,
                            "height": 640
                        },
                        {
                            "url": "http://images.gotinder.com/564f90f0df583cc63b873e60/320x320_picture_id.jpg",
                            "width": 320,
                            "height": 320
                        },
                        {
                            "url": "http://images.gotinder.com/564f90f0df583cc63b873e60/172x172_picture_id.jpg",
                            "width": 172,
                            "height": 172
                        },
                        {
                            "url": "http://images.gotinder.com/564f90f0df583cc63b873e60/84x84_picture_id.jpg",
                            "width": 84,
                            "height": 84
                        }
                    ]
                },
                {
                    "url": "http://images.gotinder.com/564f90f0df583cc63b873e60/picture_id.jpg",
                    "id": "picture_id",
                    "processedFiles": [
                        {
                            "url": "http://images.gotinder.com/564f90f0df583cc63b873e60/640x640_picture_id.jpg",
                            "width": 640,
                            "height": 640
                        },
                        {
                            "url": "http://images.gotinder.com/564f90f0df583cc63b873e60/320x320_picture_id.jpg",
                            "width": 320,
                            "height": 320
                        },
                        {
                            "url": "http://images.gotinder.com/564f90f0df583cc63b873e60/172x172_picture_id.jpg",
                            "width": 172,
                            "height": 172
                        },
                        {
                            "url": "http://images.gotinder.com/564f90f0df583cc63b873e60/84x84_picture_id.jpg",
                            "width": 84,
                            "height": 84
                        }
                    ]
                },
                {
                    "url": "http://images.gotinder.com/564f90f0df583cc63b873e60/picture_id.jpg",
                    "id": "picture_id",
                    "processedFiles": [
                        {
                            "url": "http://images.gotinder.com/564f90f0df583cc63b873e60/640x640_picture_id.jpg",
                            "width": 640,
                            "height": 640
                        },
                        {
                            "url": "http://images.gotinder.com/564f90f0df583cc63b873e60/320x320_picture_id.jpg",
                            "width": 320,
                            "height": 320
                        },
                        {
                            "url": "http://images.gotinder.com/564f90f0df583cc63b873e60/172x172_picture_id.jpg",
                            "width": 172,
                            "height": 172
                        },
                        {
                            "url": "http://images.gotinder.com/564f90f0df583cc63b873e60/84x84_picture_id.jpg",
                            "width": 84,
                            "height": 84
                        }
                    ]
                }
            ],
            "teaser": {
                "type": "school",
                "string": "school_name"
            },
            "ping_time": "2017-01-08T17:45:26.526Z",
            "schools": [
                {
                    "name": "school_name",
                    "id": "fb_school_id"
                }
            ],
            "name": "first_name",
            "uncommon_interests": [],
            "gender": 0,
            "common_interests": [],
            "s_number": 95951381,
            "hide_distance": false,
            "birth_date": "1975-01-11T19:25:00.007Z",
            "_id": "user_id"
        }, "JSON DATA OF NEXT USER" ]
}
```

HTTP code:

<table>
  <tbody>
  <tr>
    <td>200</td>
    <td>**OK**</td>
  </tr>
  <tr>
    <td>401</td>
    <td>**UNAUTHORIZED** will be received when X-Auth-Token is not set</td>
  </tr>
</table>

### Delete account
Delete your account, this can not be undone!

```
delete_account = session.delete(TINDER_HOST + '/profile')
```
