#include "authentication.h"

Authentication::Authentication(QObject *parent) : QObject(parent)
{

}

QString Authentication::token() const
{
    return m_token;
}

void Authentication::setToken(const QString &token)
{
    m_token = token;
    emit this->tokenChanged();
}

bool Authentication::isNewUser() const
{
    return m_isNewUser;
}

void Authentication::setIsNewUser(bool isNewUser)
{
    m_isNewUser = isNewUser;
    emit this->isNewUserChanged();
}

bool Authentication::isAuthenticated() const
{
    return m_isAuthenticated;
}

void Authentication::setIsAuthenticated(bool isAuthenticated)
{
    m_isAuthenticated = isAuthenticated;
    emit this->isAuthenticatedChanged();
}
