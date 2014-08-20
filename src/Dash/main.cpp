/*
 * Copyright (C) 2014 Canonical, Ltd.
 *
 * Authors:
 *  Michael Zanetti <michael.zanetti@canonical.com>
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

#include <QtQuick/QQuickView>
#include <QtGui/QGuiApplication>
#include <QtQml/QQmlEngine>
#include <QtQml/QQmlContext>
#include <QDebug>
#include <QCommandLineParser>
#include <QLibrary>
#include <libintl.h>

#include <paths.h>
#include "../MouseTouchAdaptor.h"
#include "../CachingNetworkManagerFactory.h"

int main(int argc, const char *argv[])
{
    QGuiApplication *application = new QGuiApplication(argc, (char**)argv);

    QCommandLineParser parser;
    parser.setApplicationDescription("Description: Unity 8 Shell Dash");
    parser.addHelpOption();

    QCommandLineOption mousetouchOption("mousetouch",
        "Allow the mouse to provide touch input");
    parser.addOption(mousetouchOption);

    // FIXME Remove once we drop the need of the hint
    QCommandLineOption desktopFileHintOption("desktop_file_hint",
        "The desktop_file_hint option for QtMir", "hint_file");
    parser.addOption(desktopFileHintOption);

    // Treat args with single dashes the same as arguments with two dashes
    // Ex: -fullscreen == --fullscreen
    parser.setSingleDashWordOptionMode(QCommandLineParser::ParseAsLongOptions);
    parser.process(*application);

    if (getenv("QT_LOAD_TESTABILITY")) {
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
    view->setTitle("Unity Dash");

    // You will need this if you want to interact with touch-only components using a mouse
    // Needed only when manually testing on a desktop.
    MouseTouchAdaptor *mouseTouchAdaptor = 0;
    if (parser.isSet(mousetouchOption)) {
        mouseTouchAdaptor = new MouseTouchAdaptor;
        application->installNativeEventFilter(mouseTouchAdaptor);
    }

    QUrl source(::qmlDirectory()+"Dash/DashApplication.qml");
    prependImportPaths(view->engine(), ::overrideImportPaths());
    appendImportPaths(view->engine(), ::fallbackImportPaths());

    CachingNetworkManagerFactory *managerFactory = new CachingNetworkManagerFactory();
    view->engine()->setNetworkAccessManagerFactory(managerFactory);

    view->setSource(source);
    view->show();

    int result = application->exec();

    delete view;
    delete application;

    return result;
}
