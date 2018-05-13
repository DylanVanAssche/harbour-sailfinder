#ifndef MATCH_H
#define MATCH_H

#include <QtCore/QObject>
#include <QtCore/QString>
#include "person.h"
#include "message.h"

class Match : public Person
{
    Q_OBJECT
    Q_PROPERTY(QString matchId READ matchId NOTIFY matchIdChanged)
    Q_PROPERTY(bool isSuperlike READ isSuperlike NOTIFY isSuperlikeChanged)
    Q_PROPERTY(bool isDead READ isDead NOTIFY isDeadChanged)
    Q_PROPERTY(Message* message READ message NOTIFY messageChanged)
    Q_PROPERTY(int distance READ distance NOTIFY distanceChanged)

public:
    explicit Match(QObject *parent = 0);
    explicit Match(QString id,
                   QString name,
                   QDateTime birthDate,
                   Sailfinder::Gender gender,
                   QString bio,
                   QList<Photo *> photos,
                   QString matchId,
                   bool isSuperlike,
                   bool isDead,
                   Message* message
                   );
    QString matchId() const;
    void setMatchId(const QString &matchId);
    bool isSuperlike() const;
    void setIsSuperlike(bool value);
    bool isDead() const;
    void setIsDead(bool value);
    Message *message() const;
    void setMessage(Message *messages);
    int distance() const;
    void setDistance(int distance);

signals:
    void matchIdChanged();
    void isSuperlikeChanged();
    void isDeadChanged();
    void messageChanged();
    void distanceChanged();

private:
    QString m_matchId = QString();
    bool m_isSuperlike = false;
    bool m_isDead = false;
    Message* m_message = new Message();
    int m_distance = 0;
};

#endif // MATCH_H
