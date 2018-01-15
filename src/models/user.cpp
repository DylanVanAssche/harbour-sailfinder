#include "user.h"

User::User(QObject *parent) : Person(parent)
{

}

User::User(QString id, QString name, QDateTime birthDate, Sailfinder::Gender gender, QString bio, QList<School *> schools, QList<Job *> jobs, QList<Photo *> photos, int ageMin, int ageMax, int distanceMax, Sailfinder::Gender interestedIn, QGeoCoordinate position, bool discoverable)
{
    this->setId(id);
    this->setName(name);
    this->setBirthDate(birthDate);
    this->setGender(gender);
    this->setBio(bio);
    this->setSchools(schools);
    this->setJobs(jobs);
    this->setPhotos(photos);
    this->setAgeMin(ageMin);
    this->setAgeMax(ageMax);
    this->setDistanceMax(distanceMax);
    this->setInterestedIn(interestedIn);
    this->setPosition(position);
    this->setDiscoverable(discoverable);
}

User::~User()
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

int User::ageMin() const
{
    return m_ageMin;
}

void User::setAgeMin(int ageMin)
{
    m_ageMin = ageMin;
    emit this->ageMinChanged();
}

int User::ageMax() const
{
    return m_ageMax;
}

void User::setAgeMax(int ageMax)
{
    m_ageMax = ageMax;
    emit this->ageMaxChanged();
}

int User::distanceMax() const
{
    return m_distanceMax;
}

void User::setDistanceMax(int distanceMax)
{
    m_distanceMax = distanceMax;
    emit this->distanceMaxChanged();
}

Sailfinder::Gender User::interestedIn() const
{
    return m_interestedIn;
}

void User::setInterestedIn(const Sailfinder::Gender &interestedIn)
{
    m_interestedIn = interestedIn;
    emit this->interestedInChanged();
}

QGeoCoordinate User::position() const
{
    return m_position;
}

void User::setPosition(const QGeoCoordinate &position)
{
    m_position = position;
    emit this->positionChanged();
}

bool User::discoverable() const
{
    return m_discoverable;
}

void User::setDiscoverable(bool discoverable)
{
    m_discoverable = discoverable;
    emit this->discoverableChanged();
}

QList<School *> User::schools() const
{
    return m_schools;
}

void User::setSchools(const QList<School *> &schools)
{
    m_schools = schools;
}

QList<Job *> User::jobs() const
{
    return m_jobs;
}

void User::setJobs(const QList<Job *> &jobs)
{
    m_jobs = jobs;
}
