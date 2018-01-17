#ifndef MATCH_H
#define MATCH_H

#include <QtCore/QObject>
#include <QtCore/QString>
#include "person.h"
#include "messagelistmodel.h"

class Match : public Person
{
    Q_OBJECT
    Q_PROPERTY(QString matchId READ matchId NOTIFY matchIdChanged)
    Q_PROPERTY(bool isSuperlike READ isSuperlike NOTIFY isSuperlikeChanged)
    Q_PROPERTY(bool isDead READ isDead NOTIFY isDeadChanged)
    Q_PROPERTY(MessageListModel* messages READ messages NOTIFY messagesChanged)

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
                   QList<Message *> messages
                   );
    QString matchId() const;
    void setMatchId(const QString &matchId);
    bool isSuperlike() const;
    void setIsSuperlike(bool value);
    bool isDead() const;
    void setIsDead(bool value);
    MessageListModel *messages() const;
    void setMessages(MessageListModel *messages);

signals:
    void matchIdChanged();
    void isSuperlikeChanged();
    void isDeadChanged();
    void messagesChanged();

private:
    QString m_matchId;
    bool m_isSuperlike;
    bool m_isDead;
    MessageListModel* m_messages;
};

#endif // MATCH_H
