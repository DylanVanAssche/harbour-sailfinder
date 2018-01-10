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

#ifdef QT_QML_DEBUG
#include <QtQuick>
#endif

#include <sailfishapp.h>
#include <QtCore/QScopedPointer>
#include <QtCore/QString>
#include <QtCore/QTranslator>
#include <QtGui/QGuiApplication>
#include <QtQuick/QQuickView>
#include <QtQml/QQmlEngine>

#include "logger.h"
#include "os.h"

int main(int argc, char *argv[])
{
    // Set up qml engine.
        QScopedPointer<QGuiApplication> app(SailfishApp::application(argc, argv));
        QScopedPointer<QQuickView> view(SailfishApp::createView());
        qApp->setApplicationVersion(QString(APP_VERSION));

        // Set application version and enable logging
        enableLogger(true);

        // Enable default translations
        QTranslator *translator = new QTranslator(qApp);
        QString trPath = SailfishApp::pathTo(QStringLiteral("translations")).toLocalFile();
        QString appName = app->applicationName();
        // Check if translations have been already loaded
        if (!translator->load(QLocale::system(), appName, "-", trPath))
        {
            // Load default translations if not
            translator->load(appName, trPath);
            app->installTranslator(translator);
        }
        else
        {
            translator->deleteLater();
        }

        // Register custom QML modules


        // Start the application.
        view->setSource(SailfishApp::pathTo("qml/harbour-sailfinder.qml"));
        view->show();

    return app->exec();
}
