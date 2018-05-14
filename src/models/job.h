#ifndef JOB_H
#define JOB_H

#include <QtCore/QObject>
#include <QtCore/QString>

class Job : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString id READ id NOTIFY idChanged)
    Q_PROPERTY(QString name READ name WRITE setName NOTIFY nameChanged)
    Q_PROPERTY(QString title READ title WRITE setTitle NOTIFY titleChanged)

public:
    explicit Job(QObject *parent = 0);
    explicit Job(QString id, QString name);
    explicit Job(QString id, QString name, QString title);
    explicit Job(QString name);
    QString id() const;
    void setId(const QString &id);
    QString name() const;
    void setName(const QString &name);
    QString title() const;
    void setTitle(const QString &title);

signals:
    void idChanged();
    void nameChanged();
    void titleChanged();

private:
    QString m_id = QString();
    QString m_name = QString();
    QString m_title = QString();
};

#endif // JOB_H
