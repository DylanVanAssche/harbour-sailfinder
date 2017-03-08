# NOTICE:
#
# Application name defined in TARGET has a corresponding QML filename.
# If name defined in TARGET is changed, the following needs to be done
# to match new name:
#   - corresponding QML filename must be changed
#   - desktop icon filename must be changed
#   - desktop filename must be changed
#   - icon definition filename in desktop file must be changed
#   - translation filenames have to be changed

# The name of your application
TARGET = harbour-sailfinder

CONFIG += sailfishapp

SOURCES += src/harbour-sailfinder.cpp

OTHER_FILES += qml/harbour-sailfinder.qml \
    qml/cover/CoverPage.qml \
    qml/pages/FirstPage.qml \
    rpm/harbour-sailfinder.changes.in \
    rpm/harbour-sailfinder.spec \
    rpm/harbour-sailfinder.yaml \
    translations/*.ts \
    harbour-sailfinder.desktop

SAILFISHAPP_ICONS = 86x86 108x108 128x128 256x256

# to disable building translations every time, comment out the
# following CONFIG line
CONFIG += sailfishapp_i18n

# German translation is enabled as an example. If you aren't
# planning to localize your app, remember to comment out the
# following TRANSLATIONS line. And also do not forget to
# modify the localized app name in the the .desktop file.
TRANSLATIONS += translations/harbour-sailfinder-de.ts

DISTFILES += \
    qml/pages/api.pyc \
    qml/pages/api.pyo \
    qml/pages/api.py \
    qml/pages/AboutPage.qml \
    qml/pages/ErrorPage.qml \
    qml/pages/GalleryPage.qml \
    qml/pages/MainPage.qml \
    qml/pages/MessagingPage.qml \
    qml/pages/NetworkStatus.qml \
    qml/pages/PeoplePage.qml \
    qml/pages/ProfilePage.qml \
    qml/pages/SailfinderPage.qml \
    qml/pages/SettingsPage.qml \
    qml/pages/UpdateProfilePage.qml \
    qml/pages/images/no_gif.gif \
    qml/pages/images/0.png \
    qml/pages/images/1.png \
    qml/pages/images/bio_large.png \
    qml/pages/images/bio_small.png \
    qml/pages/images/dislike_large.png \
    qml/pages/images/dislike_small.png \
    qml/pages/images/edit_small.png \
    qml/pages/images/harbour-sailfinder.png \
    qml/pages/images/instagram_large.png \
    qml/pages/images/instagram_small.png \
    qml/pages/images/job_large.png \
    qml/pages/images/job_small.png \
    qml/pages/images/lastOnline.png \
    qml/pages/images/like_large.png \
    qml/pages/images/like_small.png \
    qml/pages/images/matches_large.png \
    qml/pages/images/matches_small.png \
    qml/pages/images/message_dislike.png \
    qml/pages/images/message_like.png \
    qml/pages/images/noImage.png \
    qml/pages/images/sailfinder-notification.png \
    qml/pages/images/school_large.png \
    qml/pages/images/school_small.png \
    qml/pages/images/settings.png \
    qml/pages/images/superLike_large.png \
    qml/pages/images/superLike_small.png \
    qml/pages/images/imageSources.txt \
    qml/pages/lib/helper.js \
    qml/images/no_gif.gif \
    qml/images/0.png \
    qml/images/1.png \
    qml/images/bio_large.png \
    qml/images/bio_small.png \
    qml/images/dislike_large.png \
    qml/images/dislike_small.png \
    qml/images/edit_small.png \
    qml/images/harbour-sailfinder.png \
    qml/images/instagram_large.png \
    qml/images/instagram_small.png \
    qml/images/job_large.png \
    qml/images/job_small.png \
    qml/images/lastOnline.png \
    qml/images/like_large.png \
    qml/images/like_small.png \
    qml/images/matches_large.png \
    qml/images/matches_small.png \
    qml/images/message_dislike.png \
    qml/images/message_like.png \
    qml/images/noImage.png \
    qml/images/sailfinder-notification.png \
    qml/images/school_large.png \
    qml/images/school_small.png \
    qml/images/settings.png \
    qml/images/superLike_large.png \
    qml/images/superLike_small.png \
    qml/images/imageSources.txt \
    qml/pages/js/helper.js
