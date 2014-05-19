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
#include <QCommandLineParser>
#include <QtQuick/QQuickView>
#include <QtGui/QGuiApplication>
#include <QtQml/QQmlEngine>
#include <QtQml/QQmlContext>
#include <qpa/qplatformnativeinterface.h>
#include <QLibrary>
#include <QDebug>
#include <libintl.h>
#include <dlfcn.h>
#include <csignal>

// local
#include <paths.h>
#include "MouseTouchAdaptor.h"
#include "ApplicationArguments.h"

int startShell(int argc, const char** argv)
{
    const bool isMirServer = qgetenv("QT_QPA_PLATFORM") == "mirserver";

    QGuiApplication::setApplicationName("Unity 8");
    QGuiApplication *application;

    QCommandLineParser parser;
    parser.setApplicationDescription("Description: Unity 8 Shell");
    parser.addHelpOption();

    QCommandLineOption fullscreenOption("fullscreen",
        "Run in fullscreen");
    parser.addOption(fullscreenOption);

    QCommandLineOption framelessOption("frameless",
        "Run without window borders");
    parser.addOption(framelessOption);

    QCommandLineOption mousetouchOption("mousetouch",
        "Allow the mouse to provide touch input");
    parser.addOption(mousetouchOption);

    QCommandLineOption windowGeometryOption(QStringList() << "windowgeometry",
            "Specify the window geometry as [<width>x<height>]", "windowgeometry", "1");
    parser.addOption(windowGeometryOption);

    QCommandLineOption testabilityOption("testability",
        "DISCOURAGED: Please set QT_LOAD_TESTABILITY instead. \n \
Load the testability driver");
    parser.addOption(testabilityOption);

    application = new QGuiApplication(argc, (char**)argv);

    // Treat args with single dashes the same as arguments with two dashes
    // Ex: -fullscreen == --fullscreen
    parser.setSingleDashWordOptionMode(QCommandLineParser::ParseAsLongOptions);
    parser.process(*application);

    QString indicatorProfile = qgetenv("UNITY_INDICATOR_PROFILE");
    if (indicatorProfile.isEmpty()) {
        indicatorProfile = "phone";
    }

    resolveIconTheme();

    ApplicationArguments qmlArgs;
    if (parser.isSet(windowGeometryOption) &&
        parser.value(windowGeometryOption).split('x').size() == 2)
    {
      QStringList geom = parser.value(windowGeometryOption).split('x');
      qmlArgs.setSize(geom.at(0).toInt(), geom.at(1).toInt());
    }

    // The testability driver is only loaded by QApplication but not by QGuiApplication.
    // However, QApplication depends on QWidget which would add some unneeded overhead => Let's load the testability driver on our own.
    if (parser.isSet(testabilityOption) || getenv("QT_LOAD_TESTABILITY")) {
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
    view->engine()->setBaseUrl(QUrl::fromLocalFile(::qmlDirectory()));
    view->rootContext()->setContextProperty("applicationArguments", &qmlArgs);
    view->rootContext()->setContextProperty("indicatorProfile", indicatorProfile);
    if (parser.isSet(framelessOption)) {
        view->setFlags(Qt::FramelessWindowHint);
    }

    // You will need this if you want to interact with touch-only components using a mouse
    // Needed only when manually testing on a desktop.
    MouseTouchAdaptor *mouseTouchAdaptor = 0;
    if (parser.isSet(mousetouchOption)) {
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

    QUrl source(::qmlDirectory()+"OrientedShell.qml");
    prependImportPaths(view->engine(), ::overrideImportPaths());
    if (!isMirServer) {
        prependImportPaths(view->engine(), ::nonMirImportPaths());
    }
    appendImportPaths(view->engine(), ::fallbackImportPaths());

    view->setSource(source);

    if (isMirServer || parser.isSet(fullscreenOption)) {
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

    if (qgetenv("QT_QPA_PLATFORM") == "ubuntuclient"
            || qgetenv("QT_QPA_PLATFORM") == "ubuntumirclient") {
        setenv("QT_QPA_PLATFORM", "mirserver", 1 /* overwrite */);
    }

    return startShell(argc, argv);
}
