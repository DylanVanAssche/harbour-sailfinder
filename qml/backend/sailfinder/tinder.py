# -*- coding: utf-8 -*-
"""
Created on Thu Jan  5 19:03:49 2017

@author: Dylan Van Assche
@title: Tinder API
@description: Tinder API to interact with their servers and serve the data to QML.
@test: test/tinder_test.py
"""

#Sailfinder modules
import network, logger, constants, filemanager, sfos, giphy

#Python modules
#import datetime

"""
Recommendations:
    * Get our recommendations in the area
    * Like a recommendation
    * Dislike a recommendation
    * Superlike a recommendation
    * Report the recommendation
"""
class _Recommendations():
    def __init__(self, limit):
        self.limit = limit
        self.recs = {}
        self.progress = 0.0
        self.progress_step = 0.0
        self.size = constants.tinder.IMAGE_SIZE[0]
        logger.log_to_file.debug("Init Recommendations class")

    def get(self, size=0): #OK
        logger.log_to_file.debug("GETTING RECOMMENDATIONS", insert_line=True)
        self.progress = 0.0
        self.size = constants.tinder.IMAGE_SIZE[size]
        sfos.asynchronous.notify("recsProgress", self.progress)
        self.recs = network.connection.send("/user/recs", {"limit":constants.tinder.RECS_LIMIT})
        try:
            if isinstance(self.recs, dict):
                self.progress_step = 100.0/len(self.recs["results"])
                self._cache()
                recs_file = filemanager.File("recommendations", constants.filemanager.extension["JSON"], constants.filemanager.path["RECS"])
                recs_file.write(self.recs)
                sfos.asynchronous.data("recsData", self.recs["results"]) #When JSON doesn't have the key, return False
                return self.recs["results"]
            else:
                logger.log_to_file.warning("Recommendations data was not found in request")
                return False

        except KeyError:
            logger.log_to_file.debug("Recommendations exhausted: No users anymore in this area")
            sfos.asynchronous.data("recsData", "outOfUsers")
            return False

    def like(self, user_id): #UPGRADE!
        #recs[user]["_id"], recs[user]["s_number"], recs[user]["content_hash"], recs[user]["photos"][random(0, len(recs[user]["photos"]["id"]))])
        logger.log_to_file.debug("LIKING USER "  + user_id, insert_line=True)
        for user in range(len(self.recs["results"])):
            if self.recs["results"][user]["_id"] == user_id:
                like = network.connection.send("/like/" + user_id, http_type=constants.http.TYPE["GET"])

        if like:
            logger.log_to_file.debug("Liking OK")
            return like
        else:
            logger.log_to_file.debug("Liking failed")
            return False

    def dislike(self, user_id): #UPGRADE!
        logger.log_to_file.debug("DISLIKING USER "  + user_id, insert_line=True)
        dislike = network.connection.send("/pass/" + user_id, http_type=constants.http.TYPE["GET"])

        if dislike:
            logger.log_to_file.debug("Disliking OK")
            return True
        else:
            logger.log_to_file.debug("Disliking failed")
            return False

    def superlike(self, user_id): #UPGRADE!
        logger.log_to_file.debug("SUPERLIKING USER "  + user_id, insert_line=True)
        if meta.get()["rating"]["super_likes"]["remaining"]:
            superlike = network.connection.send("/like/" + user_id + "/super", http_type=constants.http.TYPE["POST"])
        else:
            logger.log_to_file.info("Superliking limit exceeded")
            return None

        if superlike:
            logger.log_to_file.debug("Superliking OK")
            return superlike
        else:
            logger.log_to_file.debug("Superliking failed")
            return False

    def _cache(self):
        for user in self.recs["results"]:
            if "__internal_user__" in user["photos"][0]["url"]:
               current_user = "__internal_user__"
            else:
               current_user = user["_id"]
            for photo_index, photo in enumerate(user["photos"]):
                try:
                    self.progress += (1.0/len(user["photos"]))*self.progress_step
                    sfos.asynchronous.notify("recsProgress", self.progress)
                    image_data = network.connection.send("/" + current_user + "/" + self.size + "_" + photo["id"] + ".jpg", http_type=constants.http.TYPE["GET"], host=constants.tinder.IMAGE_HOST, raw=True)
                    image_file = filemanager.File(current_user + "_" + photo["id"], constants.filemanager.extension["JPG"], constants.filemanager.path["RECS"])
                    image_file.write(image_data, True)
                    if image_data:
                        photo["processedFiles"][0]["url"] = constants.filemanager.path["RECS"] + "/" + current_user + "_" + photo["id"] + constants.filemanager.extension["JPG"]
                    else:
                        raise LookupError("Network error")
                except:
                    logger.log_to_file.trace("Caching image: " + str(photo["id"]) + " for user: " + str(current_user) + " failed")


"""
Matches:
    * Check if we have cached our matches
    * If cache too old, update our matches, else return the cached data
    * Get information about our match
    * Report the match
    * Unmatch the match
"""
class _Matches():
    def __init__(self):
        self.matches = []
        self.blocks = []
        self.goingout = []
        self.progress = 0.0
        self.progress_step = 0.0
        self.size = constants.tinder.IMAGE_SIZE[0]
        logger.log_to_file.debug("Init Matches class")

    def get(self, size=0): #OK
        logger.log_to_file.debug("GETTING MATCHES", insert_line=True)
        self.progress = 0.0
        self.size = constants.tinder.IMAGE_SIZE[size]
        sfos.asynchronous.notify("matchesProgress", self.progress)
        self.matches = updates.get()
        if isinstance(self.matches, dict):
            if len(self.matches["matches"]) == 0: #User has no matches yet
                sfos.asynchronous.notify("matchesProgress", 100.0)
                sfos.asynchronous.data("matchesData", self.matches["matches"])
                return self.matches["matches"]
            else:
                self._cacheList()
                matches_file = filemanager.File("matches", constants.filemanager.extension["JSON"], constants.filemanager.path["MATCHES"])
                matches_file.write(self.matches["matches"])
                liked_msg_file = filemanager.File("liked_messages", constants.filemanager.extension["JSON"], constants.filemanager.path["MATCHES"]) # NEEDS TO BE REMOVED
                liked_msg_file.write(self.matches["liked_messages"])
                sfos.asynchronous.notify("matchesProgress", 100.0)
                sfos.asynchronous.data("matchesData", self.matches["matches"])
                sfos.asynchronous.data("lastActive", self.matches["last_activity_date"])
                sfos.asynchronous.data("likedMessages", self.matches["liked_messages"])
                return self.matches["matches"]  #Disable incremental updates until fixed!
        else:
            logger.log_to_file.warning("Matches data was not found in request")
            return False

    def incremental(self, last_activity_date):
        logger.log_to_file.debug("GETTING INCREMENTAL UPDATE", insert_line=True)
        return updates.get(last_activity_date)

    def about(self, user_id): #OK
        logger.log_to_file.debug("GETTING ABOUT USER: " + user_id, insert_line=True)
        about_file = filemanager.File(user_id, constants.filemanager.extension["JSON"], constants.filemanager.path["MATCHES"])
        if about_file.exists() and not about_file.aged(): # Read from cache if available and not out of date
            self.about_user = about_file.read()
        else:
            self.about_user = network.connection.send("/user/"+ user_id, http_type=constants.http.TYPE["GET"])
            self.about_user = self.about_user["results"]
        self._cacheUser() #Cache images
        about_file.write(self.about_user)
        return self.about_user

    def report(self, match_id, reason, explanation=""): #OK
        logger.log_to_file.debug("REPORTING USER: " + match_id, insert_line=True)
        if len(explanation) and reason == 0 and network.connection.send("/report/" + match_id, {"cause": reason, "text": explanation}):
            logger.log_to_file.debug("Reporting for reason: " + str(reason) + " with explanation: " + explanation + " OK")
            return True

        elif network.connection.send("/report/" + match_id, {"cause": reason}):
            logger.log_to_file.debug("Reporting for reason: " + str(reason) + " OK")
            return True

        logger.log_to_file.debug("Reporting for reason: " + str(reason) + " with explanation: " + str(explanation) +  " failed")
        return False

    def unmatch(self, match_id): #OK
        logger.log_to_file.debug("UNTMATCHING MATCH", insert_line=True)
        if network.connection.send("/user/matches/" + match_id, http_type=constants.http.TYPE["DELETE"]):
            logger.log_to_file.debug("Unmatching match " + match_id + " OK")
            return True
        logger.log_to_file.debug("Unmatching match " + match_id + " failed")
        return False

    def _cacheUser(self):
        for photo_index, photo in enumerate(self.about_user["photos"]):
            try:
                image_file = filemanager.File(self.about_user["_id"] + "_" + photo["id"], constants.filemanager.extension["JPG"], constants.filemanager.path["MATCHES"])
                if image_file.exists(): #Don't download images which are already cached
                    photo["processedFiles"][0]["url"] = constants.filemanager.path["MATCHES"] + "/" + self.about_user["_id"] + "_" + photo["id"] + constants.filemanager.extension["JPG"]
                else:
                    image_data = network.connection.send("/" + self.about_user["_id"] + "/" + self.size + "_" + photo["id"] + ".jpg", http_type=constants.http.TYPE["GET"], host=constants.tinder.IMAGE_HOST, raw=True)
                    image_file.write(image_data, True)
                    if image_data:
                        photo["processedFiles"][0]["url"] = constants.filemanager.path["MATCHES"] + "/" + self.about_user["_id"] + "_" + photo["id"] + constants.filemanager.extension["JPG"]
                    else:
                        raise LookupError("Network error")
            except:
                logger.log_to_file.trace("Caching image: " + str(photo["id"]) + " for user: " + str(self.about_user["_id"]) + " failed")

    def _cacheList(self):
        self.progress_step = 100.0/(2*len(self.matches["matches"])) #2 times the size of the matches to download gifs if needed
        for user in self.matches["matches"]:
            current_user = user["person"]["_id"]
            import pyotherside
            pyotherside.send("CURRENT USER: " + str(current_user))

            try:
                if "__internal_user__" in user["person"]["photos"][0]["url"]: #Commercial partners get the id "__internal_user__" for their photos
                   current_user = "__internal_user__"
            except:
                logger.log_to_file.debug("User has no pictures, adding one...")
                user["person"]["photos"].append({"url": "", "id": "no picture", "processedFiles": [{"url": "../resources/images/icon-noimage.png", "id": "no picture"}] })

            for photo_index, photo in enumerate(user["person"]["photos"]):
                try:
                    self.progress += (1.0/len(user["person"]["photos"]))*self.progress_step
                    sfos.asynchronous.notify("matchesProgress", self.progress)
                    image_file = filemanager.File(current_user + "_" + photo["id"], constants.filemanager.extension["JPG"], constants.filemanager.path["MATCHES"])
                    if image_file.exists(): #Don't download images which are already cached
                        photo["processedFiles"][0]["url"] = constants.filemanager.path["MATCHES"] + "/" + current_user + "_" + photo["id"] + constants.filemanager.extension["JPG"]
                    else:
                        image_data = network.connection.send("/" + current_user + "/" + self.size + "_" + photo["id"] + ".jpg", http_type=constants.http.TYPE["GET"], host=constants.tinder.IMAGE_HOST, raw=True)
                        image_file.write(image_data, True)
                        if image_data:
                            photo["processedFiles"][0]["url"] = constants.filemanager.path["MATCHES"] + "/" + current_user + "_" + photo["id"] + constants.filemanager.extension["JPG"]
                        else:
                            raise LookupError("Network error")
                except:
                    logger.log_to_file.trace("Caching image: " + str(photo["id"]) + " for user: " + str(current_user) + " failed")

            for message_index, message in enumerate(user["messages"]): #Needs improving + handler for huge GIFs!
                try:
                    self.progress += (1.0/len(user["messages"]))*self.progress_step
                    sfos.asynchronous.notify("matchesProgress", self.progress)
                    if message.get("type", False) == "gif":
                        gif_id = message["fixed_height"].split("/")[4]
                        gif_file = filemanager.File(current_user + "_" + message["_id"], constants.filemanager.extension["GIF"], constants.filemanager.path["MATCHES"])
                        if gif_file.exists(): #Don't download gifs which are already cached
                            message["message"] = constants.filemanager.path["MATCHES"] + "/" + current_user + "_" + message["_id"] + constants.filemanager.extension["GIF"]
                        else:
                            gif_url = giphy.gifs.get_by_id(gif_id)["images"]["downsized"]["url"]
                            gif_data = network.connection.send(gif_url, http_type=constants.http.TYPE["GET"], host="", raw=True)
                            gif_file.write(gif_data, True)
                            if gif_data:
                                message["message"] = constants.filemanager.path["MATCHES"] + "/" + current_user + "_" + message["_id"] + constants.filemanager.extension["GIF"]
                            else:
                                raise LookupError("Network error")
                except:
                    logger.log_to_file.trace("Caching gif: " + str(message["message"]) + " for user: " + str(current_user) + " failed")


"""
Meta:
    * Get the meta data
"""
class _Meta():
    def __init__(self):
        self.meta = {}
        logger.log_to_file.debug("Init Meta class")

    def get(self): #OK
        logger.log_to_file.debug("GETTING META DATA", insert_line=True)
        self.meta = network.connection.send("/meta", http_type=constants.http.TYPE["GET"])
        if self.meta:
            meta_file = filemanager.File("meta", constants.filemanager.extension["JSON"])
            meta_file.write(self.meta)
            return self.meta
        else:
            logger.log_to_file.warning("Meta data was not found in request")
            return self.meta
"""
Updates:
    * Get our history
    * Get our incremental updates
"""
class _Updates():
    def __init__(self):
        logger.log_to_file.debug("Init Updates class")

    def get(self, last_activity_date=""): #OK
        updates = {}
        logger.log_to_file.debug("GETTING UPDATE DATA", insert_line=True)
        if len(last_activity_date): #When a date is given, get the incremental updates from then until now
            logger.log_to_file.debug("Incremental update since: " + last_activity_date)
            updates = network.connection.send("/updates", {"last_activity_date": last_activity_date}, wait=False)
            updates_file = filemanager.File(last_activity_date[:len(last_activity_date)], constants.filemanager.extension["JSON"], constants.filemanager.path["UPDATES"])
        else:
            logger.log_to_file.debug("Full update of the account history")
            updates = network.connection.send("/updates", {"last_activity_date": ""})
            updates_file = filemanager.File("history", constants.filemanager.extension["JSON"], constants.filemanager.path["UPDATES"])
        updates_file.write(updates)
        return updates

"""
Message:
    * Send the message either text or a GIF
    * Get a list of all liked messages
    * Like the message
    * Unlike the message
"""
class _Message():
    def __init__(self):
        self.liked_msg = []
        logger.log_to_file.debug("Init Message class")

    def send(self, match_id, message, gif_id="", gif=False): #OK
        logger.log_to_file.debug("SENDING MESSAGE", insert_line=True)
        if gif:
            return network.connection.send("/user/matches/" + match_id, {"type": "GIF", "message": message, "gif_id": gif_id})
        else:
            return network.connection.send("/user/matches/" + match_id, {"message": message})

    def liked(self): #OK
        logger.log_to_file.debug("GETTING LIKED MESSAGES", insert_line=True)
        liked_msg_file = filemanager.File("liked_messages", constants.filemanager.extension["JSON"], constants.filemanager.path["MATCHES"])
        self.liked_msg = liked_msg_file.read()
        return self.liked_msg

    def like(self, message_id): #OK
        logger.log_to_file.debug("LIKING MESSAGE", insert_line=True)
        return network.connection.send("/message/" + message_id + "/like")

    def unlike(self, message_id): #OK
        logger.log_to_file.debug("UNLIKING MESSAGE", insert_line=True)
        return network.connection.send("/message/" + message_id + "/like", http_type=constants.http.TYPE["DELETE"])

"""
Profile:
    * Get our profile
    * Update our profile
    * Set our location
    * Upload pictures from local drive or FB
"""
class _Profile():
    def __init__(self):
        self.profile = {}
        self.photos = []
        self.location = {}
        self.progress = 0.0
        self.size = constants.tinder.IMAGE_SIZE[0]
        logger.log_to_file.debug("Init Profile class")

    def get(self, refresh=False, size=0): #OK
        logger.log_to_file.debug("GETTING PROFILE", insert_line=True)
        self.progress = 0.0
        self.size = constants.tinder.IMAGE_SIZE[size]
        sfos.asynchronous.notify("profileProgress", self.progress)
        profile_file = filemanager.File("profile", constants.filemanager.extension["JSON"], constants.filemanager.path["PROFILE"])
        if not profile_file.exists() or profile_file.aged() or refresh==True:
            logger.log_to_file.debug("No profile data is found or refresh is requested")
            self.profile = network.connection.send("/profile", http_type=constants.http.TYPE["GET"])
            if isinstance(self.profile, dict):
                self._cache()
                profile_file.write(self.profile)
            else:
                logger.log_to_file.warning("Profile data was not found in request")
                return self.profile
        else:
            logger.log_to_file.debug("Getting profile from cache")
            sfos.asynchronous.notify("profileProgress", 100.0)
            self.profile = profile_file.read()

        if self.profile and "banned" in self.profile:
            logger.log_to_file.error("Your account has been banned, you can't use Tinder nor Sailfinder without a new account")

        sfos.asynchronous.data("profileData", self.profile)
        return self.profile

    def update(self, discoverable, age_min, age_max, gender, interested_in, distance, bio): #OK
        logger.log_to_file.debug("UPDATING PROFILE", insert_line=True)
        logger.log_to_file.debug("Updating profile: discoverable=" + str(discoverable) + " min_age=" + str(age_min) + " max_age=" + str(age_max) + " gender=" + str(gender) + " distance=" + str(distance))
        sfos.asynchronous.notify("profileProgress", 0.0)
        self.profile = network.connection.send("/profile", {"discoverable" : discoverable, "age_filter_min" : age_min, "age_filter_max" : age_max, "gender": gender, "gender_filter" : interested_in, "distance_filter" : distance, "bio": bio})
        sfos.asynchronous.notify("profileProgress", 50.0)
        profile_file = filemanager.File("profile", constants.filemanager.extension["JSON"], constants.filemanager.path["PROFILE"])
        profile_file.write(self.profile)
        sfos.asynchronous.notify("profileProgress", 100.0)
        sfos.asynchronous.data("profileData", self.profile)
        return self.profile

    def ping(self, latitude, longitude): #OK
        logger.log_to_file.debug("SETTING LOCATION", insert_line=True)
        return network.connection.send("/user/ping", {"lat": latitude, "lon": longitude})

    def delete_account(self):
        logger.log_to_file.info("DELETING ACCOUNT", insert_line=True)
        return network.connection.send("/profile", http_type=constants.http.TYPE["DELETE"])

#    def set_username(self, username): #DEPRECATED
#        logger.log_to_file.debug("SETTING USERNAME", insert_line=True)
#        self.get(True) #Refresh
#        if self.profile.has_key("username") and len(self.profile.get("username")):
#            logger.log_to_file.debug("Username already created, updating username")
#            self.profile = network.connection.send("/profile/username", {"username": username}, http_type=constants.http.TYPE["PUT"])
#        else:
#            logger.log_to_file.debug("No username created, creating username")
#            self.profile = network.connection.send("/profile/username", {"username": username})
#        return self.profile
#
#    def remove_username(self): #DEPRECATED
#        logger.log_to_file.debug("REMOVING PROFILE", insert_line=True)
#        self.get(True) #Refresh
#        if self.profile.has_key("username") and len(self.profile.get("username")):
#            logger.log_to_file.debug("Removing username")
#            self.profile = network.connection.send("/profile/username", http_type=constants.http.TYPE["DELETE"])
#            return self.profile
#        else:
#            logger.log_to_file.error("Can't delete when user has no username!")
#
#    def get_share_link(self): #DEPRECATED
#        logger.log_to_file.debug("GETTING SHARE LINK", insert_line=True)
#        self.get(True) #Refresh
#        if "username" in self.profile:
#            logger.log_to_file.debug("Getting sharelink")
#            share_link = network.connection.send("/user/" + self.profile["_id"] + "/share", http_type=constants.http.TYPE["POST"])
#            if share_link:
#                return share_link
#            else:
#                return False
#        else:
#            logger.log_to_file.error("Can't get sharelink when user has no username!")
#            return False

    def upload(self, image, working_dir, xdistance_percent=0, ydistance_percent=0, xoffset_percent=0, yoffset_percent=0, local=True): #UPGRADE!
        logger.log_to_file.debug("UPLOADING IMAGE", insert_line=True)
        if local:
            pass
            #network.connection.upload("/image?client_photo_id=ProfilePhoto/" + datetime.datetime.utcnow().isoformat(), image, working_dir)
        else:
            self.profile = network.connection.send("/media", {"transmit": "fb", "assets": [{"xdistance_percent": xdistance_percent, "ydistance_percent": ydistance_percent,"id": image,"xoffset_percent": xoffset_percent,"yoffset_percent": yoffset_percent}]})
        return self.profile

    def delete_picture(self, image_list):
        self.profile = network.connection.send("/media", {"assets": image_list}, http_type=constants.http.TYPE["DELETE"])
        return self.profile

    def schools(self, fb_schools_list):
        pass

    def job(self, fb_job_id):
        pass

    def _cache(self):
        for index, photo in enumerate(self.profile["photos"]):
            try:
                self.progress = ((index+1)/len(self.profile["photos"]))*100.0
                sfos.asynchronous.notify("profileProgress", self.progress)
                image_file = filemanager.File(self.profile["_id"] + "_" + photo["id"], constants.filemanager.extension["JPG"], constants.filemanager.path["PROFILE"])
                if image_file.exists():
                    photo["processedFiles"][0]["url"] = constants.filemanager.path["PROFILE"] + "/" + self.profile["_id"] + "_" + photo["id"] + constants.filemanager.extension["JPG"]
                else:
                    image_data = network.connection.send("/" + self.profile["_id"] + "/" + self.size + "_" + photo["id"] + ".jpg", http_type=constants.http.TYPE["GET"], host=constants.tinder.IMAGE_HOST, raw=True)
                    image_file.write(image_data, True)
                    if image_data:
                        photo["processedFiles"][0]["url"] = constants.filemanager.path["PROFILE"] + "/" + self.profile["_id"] + "_" + photo["id"] + constants.filemanager.extension["JPG"]
                    else:
                        raise LookupError("Network error")
            except:
                logger.log_to_file.trace("Caching image: " + str(photo["id"]) + " for user: " + str(self.profile["_id"]) + " failed")

"""
Social:
    * Find all Facebook friends with Tinder Social
    * Create a Tinder Social group
"""
class _Social():
    def __init__(self):
        self.fb_friends = {}

    def get_fb_friends(self): #UPGRADE
        self.fb_friends = network.connection.send("/group/friends", http_type=constants.http.TYPE["GET"])
        return self.fb_friends

    def create_group(self):
        pass

    def get_groups(self):
        # self.goingout += current_data["goingout"]
        pass

recs = _Recommendations(constants.tinder.RECS_LIMIT)
meta = _Meta()
updates = _Updates()
message = _Message()
profile = _Profile()
matches = _Matches()
social = _Social()
