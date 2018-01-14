#ifndef MESSAGE_H
#define MESSAGE_H

#include <QtCore/QObject>
#include <QtCore/QString>
#include <QtCore/QDateTime>

class Message : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString id READ id NOTIFY idChanged)
    Q_PROPERTY(QString matchId READ matchId NOTIFY matchIdChanged)
    Q_PROPERTY(QString message READ message NOTIFY messageChanged)
    Q_PROPERTY(QDateTime timestamp READ timestamp NOTIFY timestampChanged)
    Q_PROPERTY(QString fromPersonId READ fromPersonId NOTIFY fromPersonIdChanged)
    Q_PROPERTY(QString toPersonId READ toPersonId NOTIFY toPersonIdChanged)

public:
    explicit Message(QObject *parent = 0);
    explicit Message(
            QString id,
            QString matchId,
            QString message,
            QDateTime timestamp,
            QString fromPersonId,
            QString toPersonId
            );
    QString id() const;
    void setId(const QString &id);
    QString matchId() const;
    void setMatchId(const QString &matchId);
    QString message() const;
    void setMessage(const QString &message);
    QDateTime timestamp() const;
    void setTimestamp(const QDateTime &timestamp);
    QString fromPersonId() const;
    void setFromPersonId(const QString &fromPersonId);
    QString toPersonId() const;
    void setToPersonId(const QString &toPersonId);

signals:
    void idChanged();
    void matchIdChanged();
    void messageChanged();
    void timestampChanged();
    void fromPersonIdChanged();
    void toPersonIdChanged();

private:
    QString m_id;
    QString m_matchId;
    QString m_message;
    QDateTime m_timestamp;
    QString m_fromPersonId;
    QString m_toPersonId;
};

#endif // MESSAGE_H
