#ifndef PERSON_H
#define PERSON_H

#include <QtCore/QObject>
#include <QtCore/QDateTime>
#include <QtCore/QString>

#include "photo.h"
#include "photolistmodel.h"
#include "schoollistmodel.h"
#include "joblistmodel.h"

class Person : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QDateTime birthDate READ birthDate NOTIFY birthDateChanged)
    Q_PROPERTY(QString name READ name NOTIFY nameChanged)
    Q_PROPERTY(Sailfinder::Gender gender READ gender NOTIFY genderChanged)
    Q_PROPERTY(QString id READ id NOTIFY idChanged)
    Q_PROPERTY(QString bio READ bio NOTIFY bioChanged)
    Q_PROPERTY(PhotoListModel* photos READ photos NOTIFY photosChanged)
    Q_PROPERTY(SchoolListModel* schools READ schools WRITE setSchools NOTIFY schoolsChanged)
    Q_PROPERTY(JobListModel* jobs READ jobs WRITE setJobs NOTIFY jobsChanged)

public:
    explicit Person(QObject *parent = 0);
    explicit Person(QString id,
                    QString name,
                    QDateTime birthDate,
                    Sailfinder::Gender gender,
                    QString bio,
                    QList<Photo *> photos
                    );
    QDateTime birthDate() const;
    void setBirthDate(const QDateTime &birthDate);
    QString name() const;
    void setName(const QString &name);
    Sailfinder::Gender gender() const;
    void setGender(const Sailfinder::Gender &gender);
    QString id() const;
    void setId(const QString &id);
    QString bio() const;
    void setBio(const QString &bio);
    PhotoListModel *photos() const;
    void setPhotos(PhotoListModel *photos);
    SchoolListModel *schools() const;
    void setSchools(SchoolListModel *schools);
    JobListModel *jobs() const;
    void setJobs(JobListModel *jobs);

signals:
    void birthDateChanged();
    void nameChanged();
    void genderChanged();
    void idChanged();
    void bioChanged();
    void photosChanged();
    void schoolsChanged();
    void jobsChanged();

private:
    QDateTime m_birthDate = QDateTime();
    QString m_name = QString();
    Sailfinder::Gender m_gender = Sailfinder::Gender::Female;
    QString m_id = QString();
    QString m_bio = QString();
    PhotoListModel *m_photos = NULL;
    SchoolListModel* m_schools = NULL;
    JobListModel* m_jobs = NULL;
};

#endif // PERSON_H
