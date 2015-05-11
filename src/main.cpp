/*
 * Copyright (C) 2012-2015 Canonical, Ltd.
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
#include <QLibrary>
#include <QDebug>
#include <csignal>
#include <libintl.h>

// local
#include <paths.h>
#include "MouseTouchAdaptor.h"
#include "ApplicationArguments.h"
#include "CachingNetworkManagerFactory.h"
#include "UnityCommandLineParser.h"

int main(int argc, const char *argv[])
{
    bool isMirServer = false;
    if (qgetenv("QT_QPA_PLATFORM") == "ubuntumirclient") {
        setenv("QT_QPA_PLATFORM", "mirserver", 1 /* overwrite */);
        isMirServer = true;
    }

    QGuiApplication::setApplicationName("unity8");
    QGuiApplication *application;

    application = new QGuiApplication(argc, (char**)argv);

    UnityCommandLineParser parser(*application);

    QString indicatorProfile = qgetenv("UNITY_INDICATOR_PROFILE");
    if (indicatorProfile.isEmpty()) {
        indicatorProfile = "phone";
    }

    ApplicationArguments qmlArgs;
    qmlArgs.setSize(parser.windowGeometry());

    // The testability driver is only loaded by QApplication but not by QGuiApplication.
    // However, QApplication depends on QWidget which would add some unneeded overhead => Let's load the testability driver on our own.
    if (parser.hasTestability() || getenv("QT_LOAD_TESTABILITY")) {
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
    textdomain("unity8");

    QQuickView* view = new QQuickView();
    view->setResizeMode(QQuickView::SizeRootObjectToView);
    view->setColor("black");
    view->setTitle("Unity8 Shell");
    view->engine()->setBaseUrl(QUrl::fromLocalFile(::qmlDirectory()));
    view->rootContext()->setContextProperty("applicationArguments", &qmlArgs);
    view->rootContext()->setContextProperty("indicatorProfile", indicatorProfile);
    view->rootContext()->setContextProperty("shellMode", parser.mode());
    if (parser.hasFrameless()) {
        view->setFlags(Qt::FramelessWindowHint);
    }

    // You will need this if you want to interact with touch-only components using a mouse
    // Needed only when manually testing on a desktop.
    MouseTouchAdaptor *mouseTouchAdaptor = 0;
    if (parser.hasMouseToTouch()) {
        mouseTouchAdaptor = MouseTouchAdaptor::instance();
    }

    QUrl source(::qmlDirectory()+"Shell.qml");
    prependImportPaths(view->engine(), ::overrideImportPaths());
    if (!isMirServer) {
        prependImportPaths(view->engine(), ::nonMirImportPaths());
    }
    appendImportPaths(view->engine(), ::fallbackImportPaths());

    CachingNetworkManagerFactory *managerFactory = new CachingNetworkManagerFactory();
    view->engine()->setNetworkAccessManagerFactory(managerFactory);

    view->setSource(source);
    QObject::connect(view->engine(), SIGNAL(quit()), application, SLOT(quit()));

    if (isMirServer || parser.hasFullscreen()) {
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
