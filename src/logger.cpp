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
#include "logger.h"

/*
 * Enable or disable the logger
 * When disabled, all the logging messages will be redirected to the default message handler provided by QT.
 */

bool enableLogger(bool enabled) {
    if(enabled) {
        qInstallMessageHandler(handler);
        fprintf(stdout, "Enabling error handler OK\n");
        return true;
    }
    else {
        qInstallMessageHandler(0);
        fprintf(stdout, "Disabling error handler OK\n");
        return false;
    }
}

/*
 * Handler to process all kind of messages to a logfile.
 * The logfile will be cleared on launch to avoid that the used diskspace keeps increasing. If the logfile can't be openend,
 * the handler is disconnected and an error is written to stderr.
 * When QT_NO_DEBUG_OUTPUT or QT_NO_WARNING_OUTPUT are set when compiling, only the info, error and fatal messages will be logged.
 * Logfile contains a detailed description of the message like:
 *      - timestamp
 *      - file
 *      - linenumber
 *      - type
 *      - message
 */

void handler(QtMsgType type, const QMessageLogContext &context, const QString &msg)
{
    OS sfos;
    QTextStream logStream;
    QDir logdir(sfos.logLocation());
    logdir.mkpath(sfos.logLocation());
    QFile outFile(logdir.absolutePath() + "/" + sfos.logFile());

    if(clearLog) {
        if(!outFile.open(QIODevice::WriteOnly | QIODevice::Truncate)) {
            qInstallMessageHandler(0);
            fprintf(stderr, "[FATAL] Can't open logging file, logging will not function!");
        }
        logStream.setDevice(&outFile);
        clearLog = false;
        logStream << QString("%1 V%2\t%3 %4").arg(sfos.appName(), sfos.appVersion(), __DATE__, __TIME__) << endl;
        logStream << QString("%1\t%2").arg(sfos.release(), sfos.device()) << endl;
        logStream << QString("-").repeated(LINE_LENGTH) << endl;
    }
    else {
        if(!outFile.open(QIODevice::WriteOnly | QIODevice::Append)) {
            qInstallMessageHandler(0);
            fprintf(stderr, "[FATAL] Can't open logging file, logging will not function!");
        }
        logStream.setDevice(&outFile);
    }

    QString logtxt = "%1 [%2] %3:%4 (%5) \t %6";
    QString timestamp = QDateTime::currentDateTime().toString(Qt::ISODate);

    switch (type) {
        case QtInfoMsg:
            logStream << logtxt.arg(timestamp, "INFO", context.file, QString::number(context.line), context.function, msg) << endl;
            break;
        case QtDebugMsg:
            #ifndef QT_NO_DEBUG_OUTPUT
                logStream << logtxt.arg(timestamp, "DEBUG", context.file, QString::number(context.line), context.function, msg) << endl;
            #endif
            break;
        case QtWarningMsg:
            #ifndef QT_NO_WARNING_OUTPUT
                logStream << logtxt.arg(timestamp, "WARNING", context.file, QString::number(context.line), context.function, msg) << endl;
            #endif
        break;
        case QtCriticalMsg:
            logStream << logtxt.arg(timestamp, "CRITICAL", context.file, QString::number(context.line), context.function, msg) << endl;
        break;
        case QtFatalMsg:
            logStream << logtxt.arg(timestamp, "FATAL", context.file, QString::number(context.line), context.function, msg) << endl;
            abort();
        }

    logStream.flush();
    outFile.close();
    outFile.deleteLater();
}

