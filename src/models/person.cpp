#include "person.h"

Person::Person(QObject *parent) : QObject(parent)
{

}

Person::Person(QString id, QString name, QDateTime birthDate, Sailfinder::Gender gender, QString bio, QList<School *> schools, QList<Job *> jobs, QList<Photo *> photos)
{
    this->setId(id);
    this->setName(name);
    this->setBirthDate(birthDate);
    this->setGender(gender);
    this->setBio(bio);
    this->setSchools(schools);
    this->setJobs(jobs);
    this->setPhotos(photos);
}

Person::~Person()
{
    if(!this->photos().isEmpty()) {
        foreach(Photo* item, this->photos()) {
            item->deleteLater();
        }
    }

    if(!this->jobs().isEmpty()) {
        foreach(Job* item, this->jobs()) {
            item->deleteLater();
        }
    }

    if(!this->schools().isEmpty()) {
        foreach(School* item, this->schools()) {
            item->deleteLater();
        }
    }
}

QDateTime Person::birthDate() const
{
    return m_birthDate;
}

void Person::setBirthDate(const QDateTime &birthDate)
{
    m_birthDate = birthDate;
    emit this->birthDateChanged();
}

QString Person::name() const
{
    return m_name;
}

void Person::setName(const QString &name)
{
    m_name = name;
    emit this->nameChanged();
}

Sailfinder::Gender Person::gender() const
{
    return m_gender;
}

void Person::setGender(const Sailfinder::Gender &gender)
{
    m_gender = gender;
    emit this->genderChanged();
}

QString Person::id() const
{
    return m_id;
}

void Person::setId(const QString &id)
{
    m_id = id;
    emit this->idChanged();
}

QString Person::bio() const
{
    return m_bio;
}

void Person::setBio(const QString &bio)
{
    m_bio = bio;
    emit this->bioChanged();
}

QList<Photo *> Person::photos() const
{
    return m_photos;
}

void Person::setPhotos(const QList<Photo *> &photos)
{
    m_photos = photos;
    emit this->photosChanged();
}

QList<Job *> Person::jobs() const
{
    return m_jobs;
}

void Person::setJobs(const QList<Job *> &jobs)
{
    m_jobs = jobs;
    emit this->jobsChanged();
}

QList<School *> Person::schools() const
{
    return m_schools;
}

void Person::setSchools(const QList<School *> &schools)
{
    m_schools = schools;
    emit this->schoolsChanged();
}
