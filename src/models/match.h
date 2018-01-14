#ifndef MATCH_H
#define MATCH_H

#include <QtCore/QObject>
#include <QtCore/QString>
#include "person.h"

class Match : public Person
{
    Q_OBJECT
    Q_PROPERTY(int distance READ distance NOTIFY distanceChanged)
    Q_PROPERTY(QString matchId READ matchId NOTIFY matchIdChanged)
    Q_PROPERTY(bool isSuperlike READ isSuperlike NOTIFY isSuperlikeChanged)
    Q_PROPERTY(bool isDead READ isDead NOTIFY isDeadChanged)


public:
    explicit Match(QObject *parent = 0);
    explicit Match(QString id,
                   QString name,
                   QDateTime birthDate,
                   Sailfinder::Gender gender,
                   QString bio,
                   int distance,
                   QList<School *> schools,
                   QList<Job *> jobs,
                   QList<Photo *> photos,
                   QString matchId,
                   bool isSuperlike,
                   bool isDead
                   );
    int distance() const;
    void setDistance(int distance);
    QString matchId() const;
    void setMatchId(const QString &matchId);
    bool isSuperlike() const;
    void setIsSuperlike(bool value);
    bool isDead() const;
    void setIsDead(bool value);

signals:
    void distanceChanged();
    void matchIdChanged();
    void isSuperlikeChanged();
    void isDeadChanged();

private:
    int m_distance;
    QString m_matchId;
    bool m_isSuperlike;
    bool m_isDead;
    // Add here QAbstractListModel with QList<Message*>
};

#endif // MATCH_H
