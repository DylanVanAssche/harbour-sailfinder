#include "person.h"

Person::Person(QObject *parent) : QObject(parent)
{

}

Person::Person(QString id, QString name, QDateTime birthDate, Sailfinder::Gender gender, QString bio, QList<Photo *> photos)
{
    this->setId(id);
    this->setName(name);
    this->setBirthDate(birthDate);
    this->setGender(gender);
    this->setBio(bio);
    this->setPhotos(new PhotoListModel(photos));
}

QDateTime Person::birthDate() const
{
    return m_birthDate;
}

void Person::setBirthDate(const QDateTime &birthDate)
{
    m_birthDate = birthDate;
    emit this->birthDateChanged();
}

QString Person::name() const
{
    return m_name;
}

void Person::setName(const QString &name)
{
    m_name = name;
    emit this->nameChanged();
}

Sailfinder::Gender Person::gender() const
{
    return m_gender;
}

void Person::setGender(const Sailfinder::Gender &gender)
{
    m_gender = gender;
    emit this->genderChanged();
}

QString Person::id() const
{
    return m_id;
}

void Person::setId(const QString &id)
{
    m_id = id;
    emit this->idChanged();
}

QString Person::bio() const
{
    return m_bio;
}

void Person::setBio(const QString &bio)
{
    m_bio = bio;
    emit this->bioChanged();
}

PhotoListModel *Person::photos() const
{
    return m_photos;
}

void Person::setPhotos(PhotoListModel *photos)
{
    m_photos = photos;
    emit this->photosChanged();
}
