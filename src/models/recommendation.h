#ifndef RECOMMENDATION_H
#define RECOMMENDATION_H

#include <QtCore/QObject>
#include "person.h"

class Recommendation : public Person
{
    Q_OBJECT
    Q_PROPERTY(QString contentHash READ contentHash NOTIFY contentHashChanged)
    Q_PROPERTY(int sNumber READ sNumber NOTIFY sNumberChanged)
    Q_PROPERTY(int distance READ distance NOTIFY distanceChanged)

public:
    explicit Recommendation(QObject *parent = 0);
    explicit Recommendation(QString id,
                            QString name,
                            QDateTime birthDate,
                            Sailfinder::Gender gender,
                            QString bio,
                            QList<School *> schools,
                            QList<Job *> jobs,
                            QList<Photo *> photos,
                            QString contentHash,
                            int sNumber,
                            int distance
                            );
    ~Recommendation();

    QString contentHash() const;
    void setContentHash(const QString &contentHash);
    int sNumber() const;
    void setSNumber(int sNumber);
    int distance() const;
    void setDistance(int distance);
    QList<School *> schools() const;
    void setSchools(const QList<School *> &schools);
    QList<Job *> jobs() const;
    void setJobs(const QList<Job *> &jobs);

signals:
    void contentHashChanged();
    void sNumberChanged();
    void distanceChanged();
    void jobsChanged();
    void schoolsChanged();

private:
    QString m_contentHash;
    int m_sNumber;
    int m_distance;
    QList<School *> m_schools;
    QList<Job *> m_jobs;
};

#endif // RECOMMENDATION_H
