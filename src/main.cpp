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
#include "LomiriApplication.h"
#include "qmldebuggerutils.h"
#include "UnixSignalHandler.h"
#include <paths.h>

#include <QTranslator>
#include <QLibraryInfo>
#include <QLocale>
#include <QTimer>

#include <systemd/sd-daemon.h>

int main(int argc, const char *argv[])
{
    qSetMessagePattern("[%{time yyyy-MM-dd:hh:mm:ss.zzz}] %{if-category}%{category}: %{endif}%{message}");

    bool isMirServer = qgetenv("QT_QPA_PLATFORM") ==  "mirserver";
    if (qgetenv("QT_QPA_PLATFORM") == "lomirimirclient" || qgetenv("QT_QPA_PLATFORM") == "wayland") {
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

    auto *application = new LomiriApplication(argc,
                                             (char**)argv);

    UnixSignalHandler signalHandler([]{
        QGuiApplication::exit(0);
    });
    signalHandler.setupUnixSignalHandlers();

    QTranslator qtTranslator;
    if (qtTranslator.load(QLocale(), QStringLiteral("qt_"), qgetenv("SNAP"), QLibraryInfo::location(QLibraryInfo::TranslationsPath))) {
        application->installTranslator(&qtTranslator);
    }

    // When the event loop starts, signal systemd that we're ready.
    // Shouldn't do anything if we're not under systemd or it's not waiting
    // for our answer.
    QTimer::singleShot(0 /* msec */, []() {
        sd_notify(
            /* unset_environment -- we'll do so using Qt's function */ false,
            /* state */ "READY=1\n"
                        "STATUS=Lomiri is running and ready to receive connections...");

        // I'm not sure if we ever have children ourself, but just in case.
        // I don't plan to call sd_notify() again.
        qunsetenv("NOTIFY_SOCKET");
    });

    int result = application->exec();

    application->destroyResources();

    delete application;

    return result;
}
