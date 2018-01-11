#ifndef PERSON_H
#define PERSON_H

#include <QtCore/QObject>
#include <QtCore/QDateTime>
#include <QtCore/QString>

#include "photo.h"
#include "job.h"
#include "school.h"

class Person : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QDateTime birthDate READ birthDate NOTIFY birthDateChanged)
    Q_PROPERTY(int distance READ distance NOTIFY distanceChanged)
    Q_PROPERTY(QString name READ name NOTIFY nameChanged)
    Q_PROPERTY(Sailfinder::Gender gender READ gender NOTIFY genderChanged)
    Q_PROPERTY(QString id READ id NOTIFY idChanged)
    Q_PROPERTY(QString bio READ bio NOTIFY bioChanged)

public:
    explicit Person(QObject *parent = 0);
    explicit Person(QString id,
                    QString name,
                    QDateTime birthDate,
                    Sailfinder::Gender gender,
                    QString bio,
                    QList<School *> schools,
                    QList<Job *> jobs,
                    QList<Photo *> photos
                    );
    ~Person();
    QDateTime birthDate() const;
    void setBirthDate(const QDateTime &birthDate);
    int distance() const;
    void setDistance(int distance);
    QString name() const;
    void setName(const QString &name);
    Sailfinder::Gender gender() const;
    void setGender(const Sailfinder::Gender &gender);
    QString id() const;
    void setId(const QString &id);
    QString bio() const;
    void setBio(const QString &bio);
    QList<Photo *> photos() const;
    void setPhotos(const QList<Photo *> &photos);
    QList<Job *> jobs() const;
    void setJobs(const QList<Job *> &jobs);
    QList<School *> schools() const;
    void setSchools(const QList<School *> &schools);

signals:
    void birthDateChanged();
    void distanceChanged();
    void nameChanged();
    void genderChanged();
    void idChanged();
    void bioChanged();
    void photosChanged();
    void jobsChanged();
    void schoolsChanged();

private:
    QDateTime m_birthDate;
    int m_distance;
    QString m_name;
    Sailfinder::Gender m_gender;
    QString m_id;
    QString m_bio;
    QList<Photo *> m_photos;
    QList<Job *> m_jobs;
    QList<School *> m_schools;
};

#endif // PERSON_H
