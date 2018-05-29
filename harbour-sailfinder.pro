#
#   This file is part of Sailfinder.
#
#   Sailfinder is free software: you can redistribute it and/or modify
#   it under the terms of the GNU General Public License as published by
#   the Free Software Foundation, either version 3 of the License, or
#   (at your option) any later version.
#
#   Sailfinder is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#   GNU General Public License for more details.
#
#   You should have received a copy of the GNU General Public License
#   along with Sailfinder.  If not, see <http://www.gnu.org/licenses/>.
#

# The name of your application
TARGET = harbour-sailfinder

CONFIG += sailfishapp \
    c++11

# Disable warnings
CONFIG += warn_off

QT += core \
    network \
    positioning

# OS module notification support
PKGCONFIG += nemonotifications-qt5
QT += dbus

# Disable debug and warning messages while releasing for security reasons
CONFIG(release, debug|release):DEFINES += QT_NO_DEBUG_OUTPUT \
QT_NO_WARNING_OUTPUT

RESOURCES += qml/resources/resources.qrc

SOURCES += src/harbour-sailfinder.cpp \
    src/api.cpp \
    src/models/person.cpp \
    src/models/photo.cpp \
    src/models/job.cpp \
    src/models/school.cpp \
    src/logger.cpp \
    src/os.cpp \
    src/models/enum.cpp \
    src/models/match.cpp \
    src/models/recommendation.cpp \
    src/models/user.cpp \
    src/models/message.cpp \
    src/models/schoollistmodel.cpp \
    src/models/joblistmodel.cpp \
    src/models/photolistmodel.cpp \
    src/models/messagelistmodel.cpp \
    src/models/matcheslistmodel.cpp \
    src/parsers/giphy.cpp \
    src/models/gif.cpp \
    src/models/giflistmodel.cpp

DISTFILES += qml/harbour-sailfinder.qml \
    qml/pages/CoverPage.qml \
    qml/pages/FirstPage.qml \
    qml/pages/MainPage.qml \
    qml/pages/AboutPage.qml \
    qml/pages/MatchesView.qml \
    qml/pages/ProfileView.qml \
    qml/pages/RecommendationsView.qml \
    qml/pages/MessagingPage.qml \
    qml/components/NavigationBar.qml \
    qml/components/NavigationBarDelegate.qml \
    qml/components/PhotoGridLayout.qml \
    qml/components/RecommendationsBar.qml \
    qml/components/ContactsDelegate.qml \
    qml/components/Avatar.qml \
    qml/components/Spacer.qml \
    qml/components/RecommendationsBar.qml \
    qml/components/MessagingBar.qml \
    qml/components/MessagingDelegate.qml \
    qml/components/MessagingHeader.qml \
    qml/js/util.js \
    rpm/harbour-sailfinder.spec \
    translations/*.ts \
    harbour-sailfinder.desktop \
    rpm/harbour-sailfinder.changes \
    qml/js/authentication.js \
    qml/css/authentication.css \
    qml/components/RecommendationsCover.qml \
    qml/components/MatchesCover.qml \
    qml/components/ProfileCover.qml \
    qml/components/DefaultCover.qml \
    translations/harbour-sailfinder-nl_BE.ts \
    translations/harbour-sailfinder-pt_BR.ts \
    translations/harbour-sailfinder-es.ts \
    translations/harbour-sailfinder-de.ts \
    qml/components/TextMessage.qml \
    qml/components/GIFMessage.qml
    qml/components/SchoolJobDelegate.qml

SAILFISHAPP_ICONS = 86x86 108x108 128x128 256x256

# APP_VERSION retrieved from .spec file
DEFINES += APP_VERSION=\"\\\"$${VERSION}\\\"\"

# to disable building translations every time, comment out the
# following CONFIG line
CONFIG += sailfishapp_i18n \
    sailfishapp_i18n_idbased

# German translation is enabled as an example. If you aren't
# planning to localize your app, remember to comment out the
# following TRANSLATIONS line. And also do not forget to
# modify the localized app name in the the .desktop file.
TRANSLATIONS += translations/harbour-sailfinder.ts \
    translations/harbour-sailfinder-nl.ts \
    translations/harbour-sailfinder-nl_BE.ts \
    translations/harbour-sailfinder-es.ts \
    translations/harbour-sailfinder-pl.ts \
    translations/harbour-sailfinder-pt_BR.ts \
    translations/harbour-sailfinder-de.ts

HEADERS += \
    src/api.h \
    src/models/person.h \
    src/models/photo.h \
    src/models/job.h \
    src/models/school.h \
    src/logger.h \
    src/os.h \
    src/models/enum.h \
    src/models/match.h \
    src/models/recommendation.h \
    src/models/user.h \
    src/models/message.h \
    src/models/schoollistmodel.h \
    src/models/joblistmodel.h \
    src/models/photolistmodel.h \
    src/models/messagelistmodel.h \
    src/models/matcheslistmodel.h \
    src/parsers/giphy.h \
    src/models/gif.h \
    src/keys.h \
    src/models/giflistmodel.h
