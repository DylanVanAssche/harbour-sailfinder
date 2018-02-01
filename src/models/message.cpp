#include "message.h"

Message::Message(QObject *parent) : QObject(parent)
{

}

Message::Message(QString id, QString matchId, QString message, QDateTime timestamp, QString fromPersonId, QString toPersonId)
{
    this->setId(id);
    this->setMatchId(matchId);
    this->setMessage(message);
    this->setTimestamp(timestamp);
    this->setFromPersonId(fromPersonId);
    this->setToPersonId(toPersonId);
}

QString Message::id() const
{
    return m_id;
}

void Message::setId(const QString &id)
{
    m_id = id;
    emit this->idChanged();
}

QString Message::matchId() const
{
    return m_matchId;
}

void Message::setMatchId(const QString &matchId)
{
    m_matchId = matchId;
    emit this->matchIdChanged();
}

QString Message::message() const
{
    return m_message;
}

void Message::setMessage(const QString &message)
{
    m_message = message;
    emit this->messageChanged();
}

QDateTime Message::timestamp() const
{
    return m_timestamp;
}

void Message::setTimestamp(const QDateTime &timestamp)
{
    m_timestamp = timestamp;
    emit this->timestampChanged();
}

QString Message::fromPersonId() const
{
    return m_fromPersonId;
}

void Message::setFromPersonId(const QString &fromPersonId)
{
    m_fromPersonId = fromPersonId;
    emit this->fromPersonIdChanged();
}

QString Message::toPersonId() const
{
    return m_toPersonId;
}

void Message::setToPersonId(const QString &toPersonId)
{
    m_toPersonId = toPersonId;
    emit this->toPersonIdChanged();
}
