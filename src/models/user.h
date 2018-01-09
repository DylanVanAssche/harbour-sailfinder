#ifndef USER_H
#define USER_H

#include <QtCore/QObject>
#include "person.h"

class User : public Person
{
    Q_OBJECT
public:
    explicit User();

signals:

public slots:
};

#endif // USER_H
