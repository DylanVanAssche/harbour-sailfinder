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

signals:
    void matchIdChanged();
    void isSuperlikeChanged();
    void isDeadChanged();
    void messageChanged();

private:
    QString m_matchId = QString();
    bool m_isSuperlike = false;
    bool m_isDead = false;
    Message* m_message = NULL;
};

#endif // MATCH_H
