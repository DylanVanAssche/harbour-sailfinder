#include "match.h"

Match::Match(QObject *parent) : Person(parent)
{

}

Match::Match(QString id, QString name, QDateTime birthDate, Sailfinder::Gender gender, QString bio, QList<Photo *> photos, QString matchId, bool isSuperlike, bool isDead, QList<Message *> messages)
{
    this->setId(id);
    this->setName(name);
    this->setBirthDate(birthDate);
    this->setGender(gender);
    this->setBio(bio);
    this->setPhotos(new PhotoListModel(photos));
    this->setMatchId(matchId);
    this->setIsSuperlike(isSuperlike);
    this->setIsDead(isDead);
    this->setMessages(new MessageListModel(messages));
}

QString Match::matchId() const
{
    return m_matchId;
}

void Match::setMatchId(const QString &matchId)
{
    m_matchId = matchId;
    emit this->matchIdChanged();
}

bool Match::isSuperlike() const
{
    return m_isSuperlike;
}

void Match::setIsSuperlike(bool value)
{
    m_isSuperlike = value;
    emit this->isSuperlikeChanged();
}

bool Match::isDead() const
{
    return m_isDead;
}

void Match::setIsDead(bool value)
{
    m_isDead = value;
    emit this->isDeadChanged();
}

MessageListModel *Match::messages() const
{
    return m_messages;
}

void Match::setMessages(MessageListModel *messages)
{
    m_messages = messages;
    emit this->messagesChanged();
}
