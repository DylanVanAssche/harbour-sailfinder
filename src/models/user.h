#ifndef USER_H
#define USER_H

#include <QtCore/QObject>
#include <QtPositioning/QGeoCoordinate>

#include "person.h"
#include "enum.h"
#include "school.h"
#include "job.h"
#include "schoollistmodel.h"
#include "joblistmodel.h"

class User : public Person
{
    Q_OBJECT
    Q_PROPERTY(int ageMin READ ageMin WRITE setAgeMin NOTIFY ageMinChanged)
    Q_PROPERTY(int ageMax READ ageMax WRITE setAgeMax NOTIFY ageMaxChanged)
    Q_PROPERTY(int distanceMax READ distanceMax WRITE setDistanceMax NOTIFY distanceMaxChanged)
    Q_PROPERTY(Sailfinder::Gender interestedIn READ interestedIn WRITE setInterestedIn NOTIFY interestedInChanged)
    Q_PROPERTY(QGeoCoordinate position READ position NOTIFY positionChanged)
    Q_PROPERTY(bool discoverable READ discoverable WRITE setDiscoverable NOTIFY discoverableChanged)
    Q_PROPERTY(bool optimizer READ optimizer WRITE setOptimizer NOTIFY optimizerChanged)

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
                  bool discoverable,
                  bool optimizer
                  );
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
    SchoolListModel *schools() const;
    void setSchools(SchoolListModel *schools);
    JobListModel *jobs() const;
    void setJobs(JobListModel *jobs);
    bool optimizer() const;
    void setOptimizer(bool optimizer);

signals:
    void ageMinChanged();
    void ageMaxChanged();
    void distanceMaxChanged();
    void interestedInChanged();
    void positionChanged();
    void discoverableChanged();
    void jobsChanged();
    void schoolsChanged();
    void optimizerChanged();

private:
    int m_ageMin = 0;
    int m_ageMax = 0;
    int m_distanceMax = 0;
    bool m_discoverable = false;
    bool m_optimizer = false;
    Sailfinder::Gender m_interestedIn = Sailfinder::Gender::Female;
    QGeoCoordinate m_position = QGeoCoordinate();
    SchoolListModel* m_schools = NULL;
    JobListModel* m_jobs = NULL;
};

#endif // USER_H
