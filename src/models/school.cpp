#include "school.h"

School::School(QObject *parent) : QObject(parent)
{

}

School::School(QString id, QString name)
{
    this->setId(id);
    this->setName(name);
}

School::School(QString name)
{
    this->setId("");
    this->setName(name);
}

QString School::id() const
{
    return m_id;
}

void School::setId(const QString &id)
{
    m_id = id;
    emit this->idChanged();
}

QString School::name() const
{
    return m_name;
}

void School::setName(const QString &name)
{
    m_name = name;
    emit this->nameChanged();
}
