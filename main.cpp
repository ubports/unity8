/*
 * Copyright (C) 2012 Canonical, Ltd.
 *
 * Authors:
 *  Gerry Boland <gerry.boland@canonical.com>
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

// Qt
#include <QtQuick/QQuickView>
#include <QtGui/QIcon>
#include <QtGui/QGuiApplication>
#include <QtGui/QScreen>
#include <QtQml/QQmlEngine>
#include <QtQml/QQmlContext>
#include <qpa/qplatformnativeinterface.h>
#include <QLibrary>
#include <QDebug>
#include <libintl.h>
#include <dlfcn.h>
#include <csignal>

// local
#include "paths.h"
#include "MouseTouchAdaptor.h"
#include "ApplicationArguments.h"

#include <unity-mir/qmirserver.h>

namespace {

void prependImportPaths(QQmlEngine *engine, const QStringList &paths)
{
    QStringList importPathList = engine->importPathList();
    for (int i = paths.count() -1; i >= 0; i--) {
        // don't duplicate
        const QString& path = paths[i];
        QStringList::iterator iter = qFind(importPathList.begin(), importPathList.end(), path);
        if (iter == importPathList.end()) {
            engine->addImportPath(path);
        }
    }
}

/* When you append and import path to the list of import paths it will be the *last*
   place where Qt will search for QML modules.
   The usual QQmlEngine::addImportPath() actually prepends the given path.*/
void appendImportPaths(QQmlEngine *engine, const QStringList &paths)
{
    QStringList importPathList = engine->importPathList();
    Q_FOREACH(const QString& path, paths) {
        // don't duplicate
        QStringList::iterator iter = qFind(importPathList.begin(), importPathList.end(), path);
        if (iter == importPathList.end()) {
            importPathList.append(path);
        }
    }
    engine->setImportPathList(importPathList);
}

void resolveIconTheme() {
    const char *ubuntuIconTheme = getenv("UBUNTU_ICON_THEME");
    if (ubuntuIconTheme == NULL) {
        ubuntuIconTheme = "ubuntu-mobile";
    }
    QIcon::setThemeName(ubuntuIconTheme);
}
} // namespace {

int startShell(int argc, const char** argv, void* server)
{
    const bool isUbuntuMirServer = qgetenv("QT_QPA_PLATFORM") == "ubuntumirserver";

    QGuiApplication::setApplicationName(APP_NAME);
    QGuiApplication *application;
    if (isUbuntuMirServer) {
        QLibrary unityMir("unity-mir", 1);
        unityMir.load();

        typedef QGuiApplication* (*createServerApplication_t)(int&, const char **, void*);
        createServerApplication_t createQMirServerApplication = (createServerApplication_t) unityMir.resolve("createQMirServerApplication");
        if (!createQMirServerApplication) {
            qDebug() << "unable to resolve symbol: createQMirServerApplication";
            return 4;
        }

        application = createQMirServerApplication(argc, argv, server);
    } else {
        application = new QGuiApplication(argc, (char**)argv);
    }

    resolveIconTheme();

    QStringList args = application->arguments();
    ApplicationArguments qmlArgs(args);

    // The testability driver is only loaded by QApplication but not by QGuiApplication.
    // However, QApplication depends on QWidget which would add some unneeded overhead => Let's load the testability driver on our own.
    if (args.contains(QLatin1String("-testability")) || getenv("QT_LOAD_TESTABILITY")) {
        QLibrary testLib(QLatin1String("qttestability"));
        if (testLib.load()) {
            typedef void (*TasInitialize)(void);
            TasInitialize initFunction = (TasInitialize)testLib.resolve("qt_testability_init");
            if (initFunction) {
                initFunction();
            } else {
                qCritical("Library qttestability resolve failed!");
            }
        } else {
            qCritical("Library qttestability load failed!");
        }
    }

    bindtextdomain("unity8", translationDirectory().toUtf8().data());

    // Tell indicator plugin what profile to use
    qputenv("UNITY8_INDICATOR_PROFILE", INDICATOR_PROFILE);

    QQuickView* view = new QQuickView();
    view->setResizeMode(QQuickView::SizeRootObjectToView);
    view->setTitle("Qml Phone Shell");
    view->engine()->setBaseUrl(QUrl::fromLocalFile(::shellAppDirectory()));
    view->rootContext()->setContextProperty("applicationArguments", &qmlArgs);
    if (args.contains(QLatin1String("-frameless"))) {
        view->setFlags(Qt::FramelessWindowHint);
    }

    // You will need this if you want to interact with touch-only components using a mouse
    // Needed only when manually testing on a desktop.
    MouseTouchAdaptor *mouseTouchAdaptor = 0;
    if (args.contains(QLatin1String("-mousetouch"))) {
        mouseTouchAdaptor = new MouseTouchAdaptor;
        application->installNativeEventFilter(mouseTouchAdaptor);
    }

    QPlatformNativeInterface* nativeInterface = QGuiApplication::platformNativeInterface();
    /* Shell is declared as a system session so that it always receives all
       input events.
       FIXME: use the enum value corresponding to SYSTEM_SESSION_TYPE (= 1)
       when it becomes available.
    */
    nativeInterface->setProperty("ubuntuSessionType", 1);
    view->setProperty("role", 2); // INDICATOR_ACTOR_ROLE

    QUrl source(QML_FILE);
    prependImportPaths(view->engine(), ::overrideImportPaths());
    appendImportPaths(view->engine(), ::fallbackImportPaths());

    if (isUbuntuMirServer) {
        QStringList importPaths = view->engine()->importPathList();
        importPaths.replaceInStrings(QRegExp("qt5/imports$"), "qt5/imports/Unity-Mir");
        view->engine()->setImportPathList(importPaths);
    }

    view->setSource(source);

    // Make background transparent, so that the greeter can bleed through.
    // In normal shell, the background is never seen.
    QSurfaceFormat format;
    format.setAlphaBufferSize(8);
    view->setFormat(format);
    view->setColor(Qt::transparent);

    if (qgetenv("QT_QPA_PLATFORM") == "ubuntu" || isUbuntuMirServer || args.contains(QLatin1String("-fullscreen"))) {
        // First, size window equal to screen (fake a real WM fullscreen mode).
        // Then, in case we are actually running inside a windowing system,
        // nicely set actual WM fullscreen hint for its benefit.
        view->resize(view->screen()->size());
        view->showFullScreen();
    } else {
        view->show();
    }

    int result = application->exec();

    delete view;
    delete mouseTouchAdaptor;
    delete application;

    return result;
}

int main(int argc, const char *argv[])
{
    /* Workaround Qt platform integration plugin not advertising itself
       as having the following capabilities:
        - QPlatformIntegration::ThreadedOpenGL
        - QPlatformIntegration::BufferQueueingOpenGL
    */
    setenv("QML_FORCE_THREADED_RENDERER", "1", 1);
    setenv("QML_FIXED_ANIMATION_STEP", "1", 1);

    // For ubuntumirserver/ubuntumirclient
    if (qgetenv("QT_QPA_PLATFORM").startsWith("ubuntumir")) {
        setenv("QT_QPA_PLATFORM", "ubuntumirserver", 1);

        // If we use unity-mir directly, we automatically link to the Mir-server
        // platform-api bindings, which result in unexpected behaviour when
        // running the non-Mir scenario.
        QLibrary unityMir("unity-mir", 1);
        unityMir.load();
        if (!unityMir.isLoaded()) {
            qDebug() << "Library unity-mir not found/loaded";
            return 1;
        }

        typedef QMirServer* (*createServer_t)(int, const char **);
        createServer_t createQMirServer = (createServer_t) unityMir.resolve("createQMirServer");
        if (!createQMirServer) {
            qDebug() << "unable to resolve symbol: createQMirServer";
            return 2;
        }

        QMirServer* mirServer = createQMirServer(argc, argv);

        typedef int (*runWithClient_t)(QMirServer*, std::function<int(int, const char**, void*)>);
        runWithClient_t runWithClient = (runWithClient_t) unityMir.resolve("runQMirServerWithClient");
        if (!runWithClient) {
            qDebug() << "unable to resolve symbol: runWithClient";
            return 3;
        }

        return runWithClient(mirServer, startShell);
    } else {
        if (qgetenv("UPSTART_JOB") == "unity8") {
            // Emit SIGSTOP as expected by upstart, under Mir it's unity-mir that will raise it.
            // see http://upstart.ubuntu.com/cookbook/#expect-stop
            raise(SIGSTOP);
        }
        return startShell(argc, argv, nullptr);
    }
}
