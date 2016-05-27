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
    qml/pages/SecondPage.qml \
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
    rpm/harbour-sailfinder.changes \
    icons/256x256/harbour-sailfinder.png \
    icons/108x108/harbour-sailfinder.png \
    icons/128x128/harbour-sailfinder.png \
    icons/86x86/harbour-sailfinder.png \
    qml/pages/tinder.py \
    qml/pages/UpdateProfilePage.qml \
    qml/pages/SettingsPage.qml \
    qml/pages/SavedPeoplePage.qml \
    qml/pages/ProfilePage.qml \
    qml/pages/NewMatchPage.qml \
    qml/pages/MessagesPage.qml \
    qml/pages/MatchesPage.qml \
    qml/pages/MainPage.qml \
    qml/pages/LoginTinderPage.qml \
    qml/pages/LoginFacebookPage.qml \
    qml/pages/ErrorPage.qml \
    qml/pages/AboutPersonPage.qml \
    qml/pages/AboutPage.qml \
    qml/pages/dateutil/test/__init__.py \
    qml/pages/dateutil/test/_common.py \
    qml/pages/dateutil/test/test_easter.py \
    qml/pages/dateutil/test/test_imports.py \
    qml/pages/dateutil/test/test_parser.py \
    qml/pages/dateutil/test/test_relativedelta.py \
    qml/pages/dateutil/test/test_rrule.py \
    qml/pages/dateutil/test/test_tz.py \
    qml/pages/dateutil/tz/__init__.py \
    qml/pages/dateutil/tz/_common.py \
    qml/pages/dateutil/tz/tz.py \
    qml/pages/dateutil/tz/win.py \
    qml/pages/dateutil/zoneinfo/__init__.py \
    qml/pages/dateutil/zoneinfo/rebuild.py \
    qml/pages/dateutil/__init__.py \
    qml/pages/dateutil/easter.py \
    qml/pages/dateutil/parser.py \
    qml/pages/dateutil/relativedelta.py \
    qml/pages/dateutil/rrule.py \
    qml/pages/dateutil/tzwin.py \
    qml/pages/pynder/models/__init__.py \
    qml/pages/pynder/models/me.py \
    qml/pages/pynder/models/message.py \
    qml/pages/pynder/models/user.py \
    qml/pages/pynder/tests/__init__.py \
    qml/pages/pynder/tests/test_session.py \
    qml/pages/pynder/tests/utils.py \
    qml/pages/pynder/__init__.py \
    qml/pages/pynder/api.py \
    qml/pages/pynder/constants.py \
    qml/pages/pynder/errors.py \
    qml/pages/pynder/session.py \
    qml/pages/requests/packages/chardet/__init__.py \
    qml/pages/requests/packages/chardet/big5freq.py \
    qml/pages/requests/packages/chardet/big5prober.py \
    qml/pages/requests/packages/chardet/chardetect.py \
    qml/pages/requests/packages/chardet/chardistribution.py \
    qml/pages/requests/packages/chardet/charsetgroupprober.py \
    qml/pages/requests/packages/chardet/charsetprober.py \
    qml/pages/requests/packages/chardet/codingstatemachine.py \
    qml/pages/requests/packages/chardet/compat.py \
    qml/pages/requests/packages/chardet/constants.py \
    qml/pages/requests/packages/chardet/cp949prober.py \
    qml/pages/requests/packages/chardet/escprober.py \
    qml/pages/requests/packages/chardet/escsm.py \
    qml/pages/requests/packages/chardet/eucjpprober.py \
    qml/pages/requests/packages/chardet/euckrfreq.py \
    qml/pages/requests/packages/chardet/euckrprober.py \
    qml/pages/requests/packages/chardet/euctwfreq.py \
    qml/pages/requests/packages/chardet/euctwprober.py \
    qml/pages/requests/packages/chardet/gb2312freq.py \
    qml/pages/requests/packages/chardet/gb2312prober.py \
    qml/pages/requests/packages/chardet/hebrewprober.py \
    qml/pages/requests/packages/chardet/jisfreq.py \
    qml/pages/requests/packages/chardet/jpcntx.py \
    qml/pages/requests/packages/chardet/langbulgarianmodel.py \
    qml/pages/requests/packages/chardet/langcyrillicmodel.py \
    qml/pages/requests/packages/chardet/langgreekmodel.py \
    qml/pages/requests/packages/chardet/langhebrewmodel.py \
    qml/pages/requests/packages/chardet/langhungarianmodel.py \
    qml/pages/requests/packages/chardet/langthaimodel.py \
    qml/pages/requests/packages/chardet/latin1prober.py \
    qml/pages/requests/packages/chardet/mbcharsetprober.py \
    qml/pages/requests/packages/chardet/mbcsgroupprober.py \
    qml/pages/requests/packages/chardet/mbcssm.py \
    qml/pages/requests/packages/chardet/sbcharsetprober.py \
    qml/pages/requests/packages/chardet/sbcsgroupprober.py \
    qml/pages/requests/packages/chardet/sjisprober.py \
    qml/pages/requests/packages/chardet/universaldetector.py \
    qml/pages/requests/packages/chardet/utf8prober.py \
    qml/pages/requests/packages/urllib3/contrib/__init__.py \
    qml/pages/requests/packages/urllib3/contrib/appengine.py \
    qml/pages/requests/packages/urllib3/contrib/ntlmpool.py \
    qml/pages/requests/packages/urllib3/contrib/pyopenssl.py \
    qml/pages/requests/packages/urllib3/packages/ssl_match_hostname/__init__.py \
    qml/pages/requests/packages/urllib3/packages/ssl_match_hostname/_implementation.py \
    qml/pages/requests/packages/urllib3/packages/__init__.py \
    qml/pages/requests/packages/urllib3/packages/ordered_dict.py \
    qml/pages/requests/packages/urllib3/packages/six.py \
    qml/pages/requests/packages/urllib3/util/__init__.py \
    qml/pages/requests/packages/urllib3/util/connection.py \
    qml/pages/requests/packages/urllib3/util/request.py \
    qml/pages/requests/packages/urllib3/util/response.py \
    qml/pages/requests/packages/urllib3/util/retry.py \
    qml/pages/requests/packages/urllib3/util/ssl_.py \
    qml/pages/requests/packages/urllib3/util/timeout.py \
    qml/pages/requests/packages/urllib3/util/url.py \
    qml/pages/requests/packages/urllib3/__init__.py \
    qml/pages/requests/packages/urllib3/_collections.py \
    qml/pages/requests/packages/urllib3/connection.py \
    qml/pages/requests/packages/urllib3/connectionpool.py \
    qml/pages/requests/packages/urllib3/exceptions.py \
    qml/pages/requests/packages/urllib3/fields.py \
    qml/pages/requests/packages/urllib3/filepost.py \
    qml/pages/requests/packages/urllib3/poolmanager.py \
    qml/pages/requests/packages/urllib3/request.py \
    qml/pages/requests/packages/urllib3/response.py \
    qml/pages/requests/packages/__init__.py \
    qml/pages/requests/__init__.py \
    qml/pages/requests/adapters.py \
    qml/pages/requests/api.py \
    qml/pages/requests/auth.py \
    qml/pages/requests/certs.py \
    qml/pages/requests/compat.py \
    qml/pages/requests/cookies.py \
    qml/pages/requests/exceptions.py \
    qml/pages/requests/hooks.py \
    qml/pages/requests/models.py \
    qml/pages/requests/sessions.py \
    qml/pages/requests/status_codes.py \
    qml/pages/requests/structures.py \
    qml/pages/requests/utils.py

