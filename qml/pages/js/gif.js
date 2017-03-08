function search(search_word) {
    python.call("app.matches.gifs", [search_word], function(gifs) {
        gifsModel.clear() // Rmove previous GIFs from the model
        for(var gifCounter=0; gifCounter<Object.keys(gifs).length; gifCounter++) {
            gifsModel.append({
                                 url: gifs[gifCounter].images.fixed_height_small.url,
                                 original: gifs[gifCounter].images.original.url,
                                 id: gifs[gifCounter].id
                             });
        }
    });
}
