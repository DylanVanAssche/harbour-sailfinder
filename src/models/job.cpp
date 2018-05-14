#include "job.h"

Job::Job(QObject *parent) : QObject(parent)
{

}

Job::Job(QString id, QString name)
{
    this->setId(id);
    this->setName(name);
}

Job::Job(QString id, QString name, QString title)
{
    this->setId(id);
    this->setName(name);
    this->setTitle(title);
}

Job::Job(QString name)
{
    this->setId("");
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

QString Job::title() const
{
    return m_title;
}

void Job::setTitle(const QString &title)
{
    m_title = title;
    emit this->titleChanged();
}
