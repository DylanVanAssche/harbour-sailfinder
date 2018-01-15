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
                    QList<Photo *> photos
                    );
    ~Person();
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
    QList<Photo *> photos() const;
    void setPhotos(const QList<Photo *> &photos);

signals:
    void birthDateChanged();
    void nameChanged();
    void genderChanged();
    void idChanged();
    void bioChanged();
    void photosChanged();

private:
    QDateTime m_birthDate;
    QString m_name;
    Sailfinder::Gender m_gender;
    QString m_id;
    QString m_bio;
    QList<Photo *> m_photos;
};

#endif // PERSON_H
