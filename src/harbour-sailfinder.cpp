#ifdef QT_QML_DEBUG
#include <QtQuick>
#endif

#include <sailfishapp.h>


int main(int argc, char *argv[])
{
    // Register our app in the C++ engine:
    QGuiApplication* app = SailfishApp::application(argc, argv);

    // Create our view:
    QScopedPointer<QQuickView> view(SailfishApp::createView());
    view->setSource(SailfishApp::pathTo("qml/harbour-sailfinder.qml"));

    // Register the quit signal to the C++ engine:
    QObject::connect((QObject*)view->engine(), SIGNAL(quit()), app, SLOT(quit()));

    // Show our app and continue:
    view->show();
    return app->exec();
}

