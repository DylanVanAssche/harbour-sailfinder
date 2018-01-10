/*
*   This file is part of Sailfinder.
*
*   Sailfinder is free software: you can redistribute it and/or modify
*   it under the terms of the GNU General Public License as published by
*   the Free Software Foundation, either version 3 of the License, or
*   (at your option) any later version.
*
*   Sailfinder is distributed in the hope that it will be useful,
*   but WITHOUT ANY WARRANTY; without even the implied warranty of
*   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
*   GNU General Public License for more details.
*
*   You should have received a copy of the GNU General Public License
*   along with Sailfinder.  If not, see <http://www.gnu.org/licenses/>.
*/
#ifndef LOGGER_H
#define LOGGER_H

#include <QtGlobal>
#include <QtDebug>
#include <QtCore/QCoreApplication>
#include <QtCore/QString>
#include <QtCore/QTextStream>
#include <QtCore/QDebug>
#include <QtCore/QDateTime>
#include <QtCore/QFile>
#include <QtCore/QDir>
#include <QtCore/QIODevice>

#include "os.h"

#define LINE_LENGTH 100

static bool clearLog = true;
static QString name;
static QString version;
static QString compileDate;
static QString compileTime;
static QString logpath;
void handler(QtMsgType type, const QMessageLogContext &context, const QString &msg);
bool enableLogger(bool enabled);

#endif // LOGGER_H
