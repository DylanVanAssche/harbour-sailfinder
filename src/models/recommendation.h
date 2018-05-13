#ifndef RECOMMENDATION_H
#define RECOMMENDATION_H

#include <QtCore/QObject>
#include "person.h"
#include "school.h"
#include "job.h"

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
    QString contentHash() const;
    void setContentHash(const QString &contentHash);
    int sNumber() const;
    void setSNumber(int sNumber);
    int distance() const;
    void setDistance(int distance);

signals:
    void contentHashChanged();
    void sNumberChanged();
    void distanceChanged();

private:
    QString m_contentHash = QString();
    int m_sNumber = 0;
    int m_distance = 0;
};

#endif // RECOMMENDATION_H
