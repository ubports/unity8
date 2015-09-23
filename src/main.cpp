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

// libandroid-properties
#include <hybris/properties/properties.h>

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

    QGuiApplication::setApplicationName(QStringLiteral("unity8"));
    QGuiApplication *application;

    application = new QGuiApplication(argc, (char**)argv);

    UnityCommandLineParser parser(*application);

    ApplicationArguments qmlArgs;

    if (!parser.deviceName().isEmpty()) {
        qmlArgs.setDeviceName(parser.deviceName());
    } else {
        char buffer[200];
        property_get("ro.product.device", buffer /* value */, "desktop" /* default_value*/);
        qmlArgs.setDeviceName(QString(buffer));
    }

    qmlArgs.setMode(parser.mode());

    // The testability driver is only loaded by QApplication but not by QGuiApplication.
    // However, QApplication depends on QWidget which would add some unneeded overhead => Let's load the testability driver on our own.
    if (parser.hasTestability() || getenv("QT_LOAD_TESTABILITY")) {
        QLibrary testLib(QStringLiteral("qttestability"));
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
    view->setTitle(QStringLiteral("Unity8 Shell"));

    if (parser.windowGeometry().isValid()) {
        view->setWidth(parser.windowGeometry().width());
        view->setHeight(parser.windowGeometry().height());
    }

    view->engine()->setBaseUrl(QUrl::fromLocalFile(::qmlDirectory()));
    view->rootContext()->setContextProperty(QStringLiteral("applicationArguments"), &qmlArgs);
    if (parser.hasFrameless()) {
        view->setFlags(Qt::FramelessWindowHint);
    }

    // You will need this if you want to interact with touch-only components using a mouse
    // Needed only when manually testing on a desktop.
    MouseTouchAdaptor *mouseTouchAdaptor = 0;
    if (parser.hasMouseToTouch()) {
        mouseTouchAdaptor = MouseTouchAdaptor::instance();
    }

    QUrl source(::qmlDirectory() + "/OrientedShell.qml");
    prependImportPaths(view->engine(), ::overrideImportPaths());
    if (!isMirServer) {
        prependImportPaths(view->engine(), ::nonMirImportPaths());
    }
    appendImportPaths(view->engine(), ::fallbackImportPaths());

    CachingNetworkManagerFactory *managerFactory = new CachingNetworkManagerFactory();
    view->engine()->setNetworkAccessManagerFactory(managerFactory);

    view->setSource(source);
    QObject::connect(view->engine(), &QQmlEngine::quit, application, &QGuiApplication::quit);

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
