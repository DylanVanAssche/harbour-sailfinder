#include "recommendation.h"

Recommendation::Recommendation(QObject *parent) : Person(parent)
{

}

Recommendation::Recommendation(QString id, QString name, QDateTime birthDate, Sailfinder::Gender gender, QString bio, QList<School *> schools, QList<Job *> jobs, QList<Photo *> photos, QString contentHash, int sNumber, int distance)
{
    this->setId(id);
    this->setName(name);
    this->setBirthDate(birthDate);
    this->setGender(gender);
    this->setBio(bio);
    this->setSchools(schools);
    this->setJobs(jobs);
    this->setPhotos(photos);
    this->setContentHash(contentHash);
    this->setSNumber(sNumber);
    this->setDistance(distance);
}

QString Recommendation::contentHash() const
{
    return m_contentHash;
}

void Recommendation::setContentHash(const QString &contentHash)
{
    m_contentHash = contentHash;
}

int Recommendation::sNumber() const
{
    return m_sNumber;
}

void Recommendation::setSNumber(int sNumber)
{
    m_sNumber = sNumber;
}

int Recommendation::distance() const
{
    return m_distance;
}

void Recommendation::setDistance(int distance)
{
    m_distance = distance;
}
