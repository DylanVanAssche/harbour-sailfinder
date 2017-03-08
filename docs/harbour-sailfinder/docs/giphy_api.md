# GIPHY API
 _with Python Requests_

**Sniffed by myself**

```
search_word = search_word.replace(" ", "+") #Confirm with the Giphy API
gifs = session.get("http://api.giphy.com/v1/gifs/search?q=" + search_word + "&api_key=fBEDuhnVCiP16"
```

Parameter info:

<table>
  <tbody>
  <tr>
    <td>search_word</td>
    <td>**string**: The word on which you want to find GIFs.</td>
  </tr>
  </tbody>
</table>

Note: You need to replace every space in the search word by '+' for the GIPHY API.

*The GIPHY API key for the app Tinder is: `fBEDuhnVCiP16`*
