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
#include <QtCore/QList>
#include <QtPositioning/QGeoSatelliteInfoSource>
#include <QtPositioning/QGeoPositionInfoSource>

#include "os.h"
#include "models/user.h"
#include "models/photo.h"
#include "models/recommendation.h"
#include "models/match.h"
#include "models/matcheslistmodel.h"
#include "models/message.h"

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
#define SUPERLIKE_ENDPOINT "/super"

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
    Q_PROPERTY(bool canLike READ canLike NOTIFY canLikeChanged)
    Q_PROPERTY(bool canSuperlike READ canSuperlike NOTIFY canSuperlikeChanged)
    Q_PROPERTY(User* profile READ profile NOTIFY profileChanged)
    Q_PROPERTY(MatchesListModel* matchesList READ matchesList NOTIFY matchesListChanged)
    Q_PROPERTY(Recommendation* recommendation READ recommendation NOTIFY recommendationChanged)
    Q_PROPERTY(int standardPollInterval READ standardPollInterval NOTIFY standardPollIntervalChanged)
    Q_PROPERTY(int persistentPollInterval READ persistentPollInterval NOTIFY persistentPollIntervalChanged)

public:
    explicit API(QObject *parent = 0);
    ~API();
    Q_INVOKABLE void login(QString fbToken);
    Q_INVOKABLE void getMeta(int latitude, int longitude);
    Q_INVOKABLE void getProfile();
    Q_INVOKABLE void getRecommendations();
    Q_INVOKABLE void getMatchesWithMessages();
    Q_INVOKABLE void getMatchesWithoutMessages();
    Q_INVOKABLE void getUpdates(QDateTime lastActivityDate);
    Q_INVOKABLE void likeUser(QString userId);
    Q_INVOKABLE void passUser(QString userId);
    Q_INVOKABLE void superlikeUser(QString userId);
    Q_INVOKABLE void nextRecommendation();
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
    User *profile() const;
    void setProfile(User *profile);
    bool canLike() const;
    void setCanLike(bool canLike);
    int standardPollInterval() const;
    void setStandardPollInterval(int standardPollInterval);
    int persistentPollInterval() const;
    void setPersistentPollInterval(int persistentPollInterval);
    bool canSuperlike() const;
    void setCanSuperlike(bool canSuperlike);
    QList<Recommendation *> recsList() const;
    void setRecsList(const QList<Recommendation *> &recsList);
    MatchesListModel *matchesList() const;
    void setMatchesList(MatchesListModel *matchesList);
    Recommendation *recommendation() const;
    void setRecommendation(Recommendation *recommendation);

signals:
    void busyChanged();
    void tokenChanged();
    void isNewUserChanged();
    void canEditJobsChanged();
    void canEditSchoolsChanged();
    void canAddPhotosFromFacebookChanged();
    void canShowCommonConnectionsChanged();
    void canLikeChanged();
    void canSuperlikeChanged();
    void profileChanged();
    void standardPollIntervalChanged();
    void persistentPollIntervalChanged();
    void networkEnabledChanged();
    void authenticatedChanged();
    void errorOccurred(const QString &text);
    void authenticationRequested(const QString &text);
    void newMatch();
    void newSuperMatch();
    void matchesListChanged();
    void recsListChanged();
    void recommendationChanged();
    void recommendationTimeOut();

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
    bool m_canLike;
    bool m_canSuperlike;
    bool m_busy;
    bool m_networkEnabled;
    QList<Recommendation *> m_recsList;
    MatchesListModel* m_matchesList;
    User* m_profile;
    Recommendation* m_recommendation;
    int m_standardPollInterval;
    int m_persistentPollInterval;
    int positionUpdateCounter;
    int recommendationCounter;
    QGeoPositionInfoSource* positionSource;
    QNetworkAccessManager* QNAM;
    QNetworkDiskCache* QNAMCache;
    QGeoPositionInfoSource *source;
    OS SFOS;
    QNetworkRequest prepareRequest(QUrl url, QUrlQuery parameters);
    void getMatches(bool withMessages);
    void parseLogin(QJsonObject json);
    void parseMeta(QJsonObject json);
    void parseUpdates(QJsonObject json);
    void parseProfile(QJsonObject json);
    void parseRecommendations(QJsonObject json);
    void parseMatches(QJsonObject json);
    void parseLike(QJsonObject json);
    void parsePass(QJsonObject json);
    void parseSuperlike(QJsonObject json);
};

#endif // API_H
