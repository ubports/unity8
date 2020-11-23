/*
 * Copyright (C) 2012-2016 Canonical, Ltd.
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; version 3.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

// local
#include "UnityApplication.h"
#include "qmldebuggerutils.h"
#include "UnixSignalHandler.h"
#include <paths.h>

#include <QTranslator>
#include <QLibraryInfo>
#include <QLocale>

int main(int argc, const char *argv[])
{
    qSetMessagePattern("[%{time yyyy-MM-dd:hh:mm:ss.zzz}] %{if-category}%{category}: %{endif}%{message}");

    bool isMirServer = qgetenv("QT_QPA_PLATFORM") ==  "mirserver";
    if (qgetenv("QT_QPA_PLATFORM") == "ubuntumirclient" || qgetenv("QT_QPA_PLATFORM") == "wayland") {
        setenv("QT_QPA_PLATFORM", "mirserver", 1 /* overwrite */);
        isMirServer = true;

        qInfo("Using mirserver qt platform");
    }

    // If we are not running using nested mir, we need to set cursor to null
    if (!qEnvironmentVariableIsSet("MIR_SERVER_HOST_SOCKET")) {
        qInfo("Not using nested server, using null mir cursor");
        setenv("MIR_SERVER_CURSOR", "null", 1);
    }

    if (enableQmlDebugger(argc, argv)) {
        QQmlDebuggingEnabler qQmlEnableDebuggingHelper(true);
    }

    auto *application = new UnityApplication(argc,
                                             (char**)argv);

    UnixSignalHandler signalHandler([]{
        QGuiApplication::exit(0);
    });
    signalHandler.setupUnixSignalHandlers();

    QTranslator qtTranslator;
    if (qtTranslator.load(QLocale(), QStringLiteral("qt_"), qgetenv("SNAP"), QLibraryInfo::location(QLibraryInfo::TranslationsPath))) {
        application->installTranslator(&qtTranslator);
    }

    int result = application->exec();

    application->destroyResources();

    delete application;

    return result;
}
