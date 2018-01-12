#ifndef MATCH_H
#define MATCH_H

#include <QtCore/QObject>
#include "person.h"

class Match : public Person
{
    Q_OBJECT
    Q_PROPERTY(int distance READ distance NOTIFY distanceChanged)

public:
    explicit Match(QObject *parent = 0);
    explicit Match(QString id,
                   QString name,
                   QDateTime birthDate,
                   Sailfinder::Gender gender,
                   QString bio,
                   int distance,
                   QList<School *> schools,
                   QList<Job *> jobs,
                   QList<Photo *> photos
                   );

    int distance() const;
    void setDistance(int distance);

signals:
    void distanceChanged();

private:
    int m_distance;
};

#endif // MATCH_H
