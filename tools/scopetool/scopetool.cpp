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
#include <QtGui/QGuiApplication>
#include <QtQml/QQmlEngine>
#include <QtQml/QQmlContext>
#include <QScopedPointer>
#include <QDebug>
#include <QCommandLineParser>
#include <QCommandLineOption>
#include <libintl.h>


// local
#include <paths.h>
#include "registry-tracker.h"
#include "../src/UnixSignalHandler.h"


int main(int argc, char *argv[])
{
    /* Workaround Qt platform integration plugin not advertising itself
       as having the following capabilities:
        - QPlatformIntegration::ThreadedOpenGL
        - QPlatformIntegration::BufferQueueingOpenGL
    */
    setenv("QML_FORCE_THREADED_RENDERER", "1", 1);
    setenv("QML_FIXED_ANIMATION_STEP", "1", 1);

    // ignore favorites in unity-scopes-shell plugin
    setenv("UNITY_SCOPES_NO_FAVORITES", "1", 1);

    QGuiApplication::setApplicationName("Unity Scope Tool");
    QGuiApplication *application;
    application = new QGuiApplication(argc, argv);

    QCommandLineParser parser;
    parser.setApplicationDescription("Unity Scope Tool\n\n"
    "This tool allows development and testing of scopes. Running it without\n"
    "any arguments will open a session to all scopes available on the system.\n"
    "Otherwise passing a path to a scope config file will open a session with\n"
    "only that scope (assuming that the binary implementing the scope can be\n"
    "found in the same directory as the config file).");
    QCommandLineOption helpOption = parser.addHelpOption();
    parser.addPositionalArgument("scopes", "Paths to scope config files to spawn, optionally.", "[scopes...]");

    QCommandLineOption includeSystemScopes("include-system-scopes",
        "Initialize the registry with scopes installed on this system");
    QCommandLineOption includeServerScopes("include-server-scopes",
        "Initialize the registry with scopes on the default server");

    parser.addOption(includeServerScopes);
    parser.addOption(includeSystemScopes);

    parser.parse(application->arguments());

    if (parser.isSet(helpOption)) {
        parser.showHelp();
    }

    QStringList extraScopes = parser.positionalArguments();

    QScopedPointer<RegistryTracker> tracker;
    if (!extraScopes.isEmpty()) {
        bool systemScopes = parser.isSet(includeSystemScopes);
        bool serverScopes = parser.isSet(includeServerScopes);
        tracker.reset(new RegistryTracker(extraScopes, systemScopes, serverScopes));
    }

    bindtextdomain("unity8", translationDirectory().toUtf8().data());
    textdomain("unity8");

    QQuickView* view = new QQuickView();
    view->setResizeMode(QQuickView::SizeRootObjectToView);
    view->setTitle(QGuiApplication::applicationName());
    view->engine()->setBaseUrl(QUrl::fromLocalFile(::qmlDirectory()));

    QUrl source(::qmlDirectory() + "/ScopeTool.qml");
    prependImportPaths(view->engine(), ::overrideImportPaths());
    prependImportPaths(view->engine(), ::nonMirImportPaths());
    appendImportPaths(view->engine(), ::fallbackImportPaths());

    view->setSource(source);

    view->show();

    UnixSignalHandler signal_handler([]{
        QGuiApplication::exit(0);
    });
    signal_handler.setupUnixSignalHandlers();

    int result = application->exec();

    delete view;
    delete application;

    return result;
}
