#include "job.h"

Job::Job(QObject *parent) : QObject(parent)
{

}

Job::Job(QString id, QString name)
{
    this->setId(id);
    this->setName(name);
}

QString Job::id() const
{
    return m_id;
}

void Job::setId(const QString &id)
{
    m_id = id;
    emit this->idChanged();
}

QString Job::name() const
{
    return m_name;
}

void Job::setName(const QString &name)
{
    m_name = name;
    emit this->nameChanged();
}
