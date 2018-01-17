#ifndef SCHOOL_H
#define SCHOOL_H

#include <QtCore/QObject>
#include <QtCore/QString>

class School : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString id READ id NOTIFY idChanged)
    Q_PROPERTY(QString name READ name NOTIFY nameChanged)

public:
    explicit School(QObject *parent = 0);
    explicit School(QString id, QString name);
    explicit School(QString name);
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

#endif // SCHOOL_H
