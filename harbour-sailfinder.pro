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

SOURCES += src/harbour-sailfinder.cpp \
    #src/api.cpp \
    #src/models/user.cpp \
    #src/models/recommendation.cpp \
    #src/models/match.cpp \
    #src/models/person.cpp

DISTFILES += qml/harbour-sailfinder.qml \
    qml/cover/CoverPage.qml \
    qml/pages/FirstPage.qml \
    rpm/harbour-sailfinder.changes.in \
    rpm/harbour-sailfinder.changes.run.in \
    rpm/harbour-sailfinder.spec \
    rpm/harbour-sailfinder.yaml \
    translations/*.ts \
    harbour-sailfinder.desktop

SAILFISHAPP_ICONS = 86x86 108x108 128x128

# to disable building translations every time, comment out the
# following CONFIG line
CONFIG += sailfishapp_i18n

# German translation is enabled as an example. If you aren't
# planning to localize your app, remember to comment out the
# following TRANSLATIONS line. And also do not forget to
# modify the localized app name in the the .desktop file.
TRANSLATIONS += translations/harbour-sailfinder-de.ts

HEADERS += \
    #src/api.h \
    #src/models/user.h \
    #src/models/recommendation.h \
    #src/models/match.h \
    #src/models/person.h
