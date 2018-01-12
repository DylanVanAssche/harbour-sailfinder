#ifndef JOB_H
#define JOB_H

#include <QtCore/QObject>
#include <QtCore/QString>

class Job : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString id READ id NOTIFY idChanged)
    Q_PROPERTY(QString name READ name WRITE setName NOTIFY nameChanged)

public:
    explicit Job(QObject *parent = 0);
    explicit Job(QString id, QString name);
    explicit Job(QString name);
    QString id() const;
    void setId(const QString &id);
    QString name() const;
    void setName(const QString &name);

signals:
    void idChanged();
    void nameChanged();

private:
    QString m_id;
    QString m_name;
};

#endif // JOB_H
