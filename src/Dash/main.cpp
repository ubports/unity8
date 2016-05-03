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
#include "../qmldebuggerutils.h"
#ifdef UNITY8_ENABLE_TOUCH_EMULATION
    #include "../MouseTouchAdaptor.h"
#endif
#include "../CachingNetworkManagerFactory.h"

int main(int argc, const char *argv[])
{
    if (enableQmlDebugger(argc, argv)) {
        QQmlDebuggingEnabler qQmlEnableDebuggingHelper(true);
    }

    QGuiApplication *application = new QGuiApplication(argc, (char**)argv);

    QCommandLineParser parser;
    parser.setApplicationDescription(QStringLiteral("Description: Unity 8 Shell Dash"));
    parser.addHelpOption();

    QCommandLineOption mousetouchOption(QStringLiteral("mousetouch"),
        QStringLiteral("Allow the mouse to provide touch input"));
    parser.addOption(mousetouchOption);

    QCommandLineOption windowGeometryOption(QStringList() << QStringLiteral("windowgeometry"),
        QStringLiteral("Specify the window geometry as [<width>x<height>]"), QStringLiteral("windowgeometry"), QStringLiteral("1"));
    parser.addOption(windowGeometryOption);

   // FIXME Remove once we drop the need of the hint
    QCommandLineOption desktopFileHintOption(QStringLiteral("desktop_file_hint"),
        QStringLiteral("The desktop_file_hint option for QtMir"), QStringLiteral("hint_file"));
    parser.addOption(desktopFileHintOption);

    // Treat args with single dashes the same as arguments with two dashes
    // Ex: -fullscreen == --fullscreen
    parser.setSingleDashWordOptionMode(QCommandLineParser::ParseAsLongOptions);
    parser.process(*application);

    if (getenv("QT_LOAD_TESTABILITY")) {
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

    if (parser.isSet(windowGeometryOption) &&
        parser.value(windowGeometryOption).split('x').size() == 2)
    {
        QStringList geom = parser.value(windowGeometryOption).split('x');
        QSize windowSize(geom.at(0).toInt(), geom.at(1).toInt());
        if (windowSize.isValid()) {
            view->setWidth(windowSize.width());
            view->setHeight(windowSize.height());
        }
    }

    view->setTitle(QStringLiteral("Scopes"));

    #ifdef UNITY8_ENABLE_TOUCH_EMULATION
    // You will need this if you want to interact with touch-only components using a mouse
    // Needed only when manually testing on a desktop.
    MouseTouchAdaptor *mouseTouchAdaptor = 0;
    if (parser.isSet(mousetouchOption)) {
        mouseTouchAdaptor = MouseTouchAdaptor::instance();
    }
    #endif

    QUrl source(::qmlDirectory() + "/Dash/DashApplication.qml");
    prependImportPaths(view->engine(), ::overrideImportPaths());
    appendImportPaths(view->engine(), ::fallbackImportPaths());

    CachingNetworkManagerFactory *managerFactory = new CachingNetworkManagerFactory();
    view->engine()->setNetworkAccessManagerFactory(managerFactory);

    view->setSource(source);
    view->show();

    int result = application->exec();

    delete view;

    #ifdef UNITY8_ENABLE_TOUCH_EMULATION
    delete mouseTouchAdaptor;
    #endif

    delete application;

    return result;
}
