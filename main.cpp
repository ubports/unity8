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
#include <QtQml/QQmlEngine>
#include <QtQml/QQmlContext>
#include <qpa/qplatformnativeinterface.h>
#include <QLibrary>
#include <libintl.h>

// local
#include "paths.h"
#include "MouseTouchAdaptor.h"

namespace {

void prependImportPaths(QQmlEngine *engine, const QStringList &paths)
{
    QStringList importPathList = engine->importPathList();
    for (int i = paths.count() -1; i >= 0; i--) {
        importPathList.prepend(paths[i]);
    }
    engine->setImportPathList(importPathList);
}

/* When you append and import path to the list of import paths it will be the *last*
   place where Qt will search for QML modules.
   The usual QQmlEngine::addImportPath() actually prepends the given path.*/
void appendImportPaths(QQmlEngine *engine, const QStringList &paths)
{
    QStringList importPathList = engine->importPathList();
    importPathList.append(paths);
    engine->setImportPathList(importPathList);
}

void resolveIconTheme() {
    const char *ubuntuIconTheme = getenv("UBUNTU_ICON_THEME");
    if (ubuntuIconTheme != NULL) {
        QIcon::setThemeName(ubuntuIconTheme);
    }
}
} // namespace {

int main(int argc, char** argv)
{
    /* Workaround Qt platform integration plugin not advertising itself
       as having the following capabilities:
        - QPlatformIntegration::ThreadedOpenGL
        - QPlatformIntegration::BufferQueueingOpenGL
    */
    setenv("QML_FORCE_THREADED_RENDERER", "1", 1);
    setenv("QML_FIXED_ANIMATION_STEP", "1", 1);

    QGuiApplication::setApplicationName("Qml Phone Shell");
    QGuiApplication application(argc, argv);

    resolveIconTheme();

    QStringList args = application.arguments();

    // The testability driver is only loaded by QApplication but not by QGuiApplication.
    // However, QApplication depends on QWidget which would add some unneeded overhead => Let's load the testability driver on our own.
    if (args.contains(QLatin1String("-testability"))) {
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

    QQuickView* view = new QQuickView();
    view->setResizeMode(QQuickView::SizeRootObjectToView);
    view->setTitle("Qml Phone Shell");
    view->engine()->setBaseUrl(QUrl::fromLocalFile(::shellAppDirectory()));
    if (args.contains(QLatin1String("-frameless"))) {
        view->setFlags(Qt::FramelessWindowHint);
    }

    // You will need this if you want to interact with touch-only components using a mouse
    // Needed only when manually testing on a desktop.
    MouseTouchAdaptor *mouseTouchAdaptor = 0;
    if (args.contains(QLatin1String("-mousetouch"))) {
        mouseTouchAdaptor = new MouseTouchAdaptor;
        mouseTouchAdaptor->setTargetWindow(view);
        application.installNativeEventFilter(mouseTouchAdaptor);
    }

    QPlatformNativeInterface* nativeInterface = QGuiApplication::platformNativeInterface();
    /* Shell is declared as a system session so that it always receives all
       input events.
       FIXME: use the enum value corresponding to SYSTEM_SESSION_TYPE (= 1)
       when it becomes available.
    */
    nativeInterface->setProperty("ubuntuSessionType", 1);
    view->setProperty("role", 2); // INDICATOR_ACTOR_ROLE

    QUrl source("Shell.qml");
    prependImportPaths(view->engine(), QStringList() << ::shellAppDirectory());
    prependImportPaths(view->engine(), ::shellImportPaths());
    appendImportPaths(view->engine(), QStringList() << ::fakePluginsImportPath());
    view->setSource(source);
    view->setColor("transparent");

    if (qgetenv("QT_QPA_PLATFORM") == "ubuntu" || args.contains(QLatin1String("-fullscreen"))) {
        view->showFullScreen();
    } else {
        if (args.contains(QLatin1String("-geometry")) && args.size() > args.indexOf(QLatin1String("-geometry")) + 1) {
            QStringList geometryArg = args.at(args.indexOf(QLatin1String("-geometry")) + 1).split('x');
            if (geometryArg.size() == 2) {
                view->resize(geometryArg.at(0).toInt(), geometryArg.at(1).toInt());
            }
        }
        view->show();
    }

    int result = application.exec();

    delete mouseTouchAdaptor;

    return result;
}
