#ifndef USER_H
#define USER_H

#include <QtCore/QObject>
#include <QtPositioning/QGeoCoordinate>

#include "person.h"
#include "enum.h"

class User : public Person
{
    Q_OBJECT
    Q_PROPERTY(int ageMin READ ageMin WRITE setAgeMin NOTIFY ageMinChanged)
    Q_PROPERTY(int ageMax READ ageMax WRITE setAgeMax NOTIFY ageMaxChanged)
    Q_PROPERTY(int distanceMax READ distanceMax WRITE setDistanceMax NOTIFY distanceMaxChanged)
    Q_PROPERTY(Sailfinder::Gender interestedIn READ interestedIn WRITE setInterestedIn NOTIFY interestedInChanged)
    Q_PROPERTY(QGeoCoordinate position READ position NOTIFY positionChanged)
    Q_PROPERTY(bool discoverable READ discoverable WRITE setDiscoverable NOTIFY discoverableChanged)

public:
    explicit User(QObject *parent = 0);
    explicit User(QString id,
                  QString name,
                  QDateTime birthDate,
                  Sailfinder::Gender gender,
                  QString bio,
                  QList<School *> schools,
                  QList<Job *> jobs,
                  QList<Photo *> photos,
                  int ageMin,
                  int ageMax,
                  int distanceMax,
                  Sailfinder::Gender interestedIn,
                  QGeoCoordinate position,
                  bool discoverable
                  );
    ~User();

    int ageMin() const;
    void setAgeMin(int ageMin);
    int ageMax() const;
    void setAgeMax(int ageMax);
    int distanceMax() const;
    void setDistanceMax(int distanceMax);
    Sailfinder::Gender interestedIn() const;
    void setInterestedIn(const Sailfinder::Gender &interestedIn);
    QGeoCoordinate position() const;
    void setPosition(const QGeoCoordinate &position);
    bool discoverable() const;
    void setDiscoverable(bool discoverable);
    QList<School *> schools() const;
    void setSchools(const QList<School *> &schools);
    QList<Job *> jobs() const;
    void setJobs(const QList<Job *> &jobs);

signals:
    void ageMinChanged();
    void ageMaxChanged();
    void distanceMaxChanged();
    void interestedInChanged();
    void positionChanged();
    void discoverableChanged();
    void jobsChanged();
    void schoolsChanged();

private:
    int m_ageMin;
    int m_ageMax;
    int m_distanceMax;
    bool m_discoverable;
    Sailfinder::Gender m_interestedIn;
    QGeoCoordinate m_position;
    QList<School *> m_schools;
    QList<Job *> m_jobs;
};

#endif // USER_H
