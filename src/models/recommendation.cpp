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

Recommendation::~Recommendation()
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

QList<School *> Recommendation::schools() const
{
    return m_schools;
}

void Recommendation::setSchools(const QList<School *> &schools)
{
    m_schools = schools;
}

QList<Job *> Recommendation::jobs() const
{
    return m_jobs;
}

void Recommendation::setJobs(const QList<Job *> &jobs)
{
    m_jobs = jobs;
}
