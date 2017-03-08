# Facebook Graph API
 _with Python Requests_

**Only for reference since the API clearly documented on the Facebook Developer pages.**

### Get all albums of users
```
fb_albums = session.get("https://graph.facebook.com/v2.6/" + fb_user_id + "/albums?access_token=" + fb_token)
```

Parameter info:

<table>
  <tbody>
  <tr>
    <td>fb_user_id</td>
    <td>**string**: The user id from Facebook for this app.</td>
  </tr>
  <tr>
    <td>fb_token</td>
    <td>**string**: A valid FB token for this app and this user.</td>
  </tr>
  </tbody>
</table>

### Get all photos of users
```
fb_photos = session.get("https://graph.facebook.com/v2.6/" + fb_album_id + "/photos?access_token=" + fb_token)
```

Parameter info:

<table>
  <tbody>
  <tr>
    <td>fb_album_id</td>
    <td>**string**: The album id from Facebook which can be get by quering all the albums from Facebook.</td>
  </tr>
  <tr>
    <td>fb_token</td>
    <td>**string**: A valid FB token for this app and this user.</td>
  </tr>
  </tbody>
</table>
