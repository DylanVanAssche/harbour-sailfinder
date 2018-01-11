/*
*   This file is part of Sailfinder.
*
*   Sailfinder is free software: you can redistribute it and/or modify
*   it under the terms of the GNU General Public License as published by
*   the Free Software Foundation, either version 3 of the License, or
*   (at your option) any later version.
*
*   Sailfinder is distributed in the hope that it will be useful,
*   but WITHOUT ANY WARRANTY; without even the implied warranty of
*   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
*   GNU General Public License for more details.
*
*   You should have received a copy of the GNU General Public License
*   along with Sailfinder.  If not, see <http://www.gnu.org/licenses/>.
*/

#ifndef API_H
#define API_H

#include <QtGlobal>
#include <QtNetwork/QNetworkAccessManager>
#include <QtNetwork/QNetworkRequest>
#include <QtNetwork/QNetworkReply>
#include <QtNetwork/QNetworkConfigurationManager>
#include <QtNetwork/QNetworkDiskCache>
#include <QtCore/QObject>
#include <QtCore/QString>
#include <QtCore/QJsonDocument>
#include <QtCore/QVariantMap>
#include <QtPositioning/QGeoSatelliteInfoSource>
#include <QtPositioning/QGeoPositionInfoSource>

#include "os.h"
#define POSITION_MAX_UPDATE 10
#define TINDER_USER_AGENT "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/63.0.3239.108 Safari/537.36"
#define AUTH_FACEBOOK_ENDPOINT "https://api.gotinder.com/v2/auth/login/facebook"
#define META_ENDPOINT "https://api.gotinder.com/v2/meta"
#define UPDATES_ENDPOINT "https://api.gotinder.com/updates"
#define RECS_ENDPOINT "https://api.gotinder.com/recs/core"
#define MATCHES_ENDPOINT "https://api.gotinder.com/v2/matches"
#define PROFILE_ENDPOINT "https://api.gotinder.com/v2/profile"
#define LIKE_ENDPOINT "https://api.gotinder.com/like"
#define PASS_ENDPOINT "https://api.gotinder.com/pass"
#define SUPERLIKE_ENDPOINT "https://api.gotinder.com/superlike"

class API : public QObject
{
    Q_OBJECT
    Q_PROPERTY(bool busy READ busy NOTIFY busyChanged)
    Q_PROPERTY(QString token READ token NOTIFY tokenChanged)
    Q_PROPERTY(bool authenticated READ authenticated NOTIFY authenticatedChanged)
    Q_PROPERTY(bool canEditJobs READ canEditJobs NOTIFY canEditJobsChanged)
    Q_PROPERTY(bool canEditSchools READ canEditSchools NOTIFY canEditSchoolsChanged)
    Q_PROPERTY(bool canAddPhotosFromFacebook READ canAddPhotosFromFacebook NOTIFY canAddPhotosFromFacebookChanged)
    Q_PROPERTY(bool canShowCommonConnections READ canShowCommonConnections NOTIFY canShowCommonConnectionsChanged)

public:
    explicit API(QObject *parent = 0);
    ~API();
    Q_INVOKABLE void login(QString fbToken);
    Q_INVOKABLE void getMeta(int latitude, int longitude);
    QString token() const;
    void setToken(const QString &token);
    bool networkEnabled() const;
    void setNetworkEnabled(bool networkEnabled);
    bool busy() const;
    void setBusy(bool busy);
    bool isNewUser() const;
    void setIsNewUser(bool isNewUser);
    bool authenticated() const;
    void setAuthenticated(bool authenticated);
    bool canEditJobs() const;
    void setCanEditJobs(bool canEditJobs);
    bool canEditSchools() const;
    void setCanEditSchools(bool canEditSchools);
    bool canAddPhotosFromFacebook() const;
    void setCanAddPhotosFromFacebook(bool canAddPhotosFromFacebook);
    bool canShowCommonConnections() const;
    void setCanShowCommonConnections(bool canShowCommonConnections);

signals:
    void busyChanged();
    void tokenChanged();
    void isNewUserChanged();
    void canEditJobsChanged();
    void canEditSchoolsChanged();
    void canAddPhotosFromFacebookChanged();
    void canShowCommonConnectionsChanged();
    void networkEnabledChanged();
    void authenticatedChanged();
    void errorOccurred(const QString &text);
    void authenticationRequested(const QString &text);

public slots:
    void networkAccessible(QNetworkAccessManager::NetworkAccessibility state);
    void sslErrors(QNetworkReply* reply, QList<QSslError> sslError);
    void finished(QNetworkReply *reply);
    void positionUpdated(const QGeoPositionInfo &info);

private:
    QString m_token;
    bool m_isNewUser;
    bool m_authenticated;
    bool m_canEditJobs;
    bool m_canEditSchools;
    bool m_canAddPhotosFromFacebook;
    bool m_canShowCommonConnections;
    bool m_busy;
    bool m_networkEnabled;
    int positionUpdateCounter;
    QGeoPositionInfoSource* positionSource;
    QNetworkAccessManager* QNAM;
    QNetworkDiskCache* QNAMCache;
    QGeoPositionInfoSource *source;
    OS SFOS;
    QNetworkRequest prepareRequest(QUrl url, QUrlQuery parameters);
    void parseLogin(QJsonObject json);
    void parseMeta(QJsonObject json);
    void parseUpdates(QJsonObject json);
    void parseProfile(QJsonObject json);
};

#endif // API_H