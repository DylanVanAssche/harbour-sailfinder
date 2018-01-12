#include "match.h"

Match::Match(QObject *parent) : Person(parent)
{

}

Match::Match(QString id, QString name, QDateTime birthDate, Sailfinder::Gender gender, QString bio, int distance, QList<School *> schools, QList<Job *> jobs, QList<Photo *> photos)
{
    this->setId(id);
    this->setName(name);
    this->setBirthDate(birthDate);
    this->setGender(gender);
    this->setBio(bio);
    this->setDistance(distance);
    this->setSchools(schools);
    this->setJobs(jobs);
    this->setPhotos(photos);
}

int Match::distance() const
{
    return m_distance;
}

void Match::setDistance(int distance)
{
    m_distance = distance;
    emit this->distanceChanged();
}
