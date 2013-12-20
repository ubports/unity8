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
#include <libintl.h>


// local
#include <paths.h>
#include "registry-tracker.h"


int main(int argc, const char *argv[])
{
    /* Workaround Qt platform integration plugin not advertising itself
       as having the following capabilities:
        - QPlatformIntegration::ThreadedOpenGL
        - QPlatformIntegration::BufferQueueingOpenGL
    */
    setenv("QML_FORCE_THREADED_RENDERER", "1", 1);
    setenv("QML_FIXED_ANIMATION_STEP", "1", 1);

    QGuiApplication::setApplicationName("Unity Scope Tool");
    QGuiApplication *application;
    application = new QGuiApplication(argc, (char**)argv);

    QStringList arguments = application->arguments();
    QString scopesDir;
    if (arguments.contains("--scope-dir")) {
        int idx = arguments.indexOf("--scope-dir");
        scopesDir = arguments[idx+1];
    }

    QScopedPointer<RegistryTracker> tracker;
    if (!scopesDir.isEmpty()) {
        tracker.reset(new RegistryTracker(scopesDir));
    }

    resolveIconTheme();

    bindtextdomain("unity8", translationDirectory().toUtf8().data());

    QQuickView* view = new QQuickView();
    view->setResizeMode(QQuickView::SizeRootObjectToView);
    view->setTitle(QGuiApplication::applicationName());
    view->engine()->setBaseUrl(QUrl::fromLocalFile(::qmlDirectory()));

    QUrl source(::qmlDirectory() + "ScopeTool.qml");
    prependImportPaths(view->engine(), ::overrideImportPaths());
    appendImportPaths(view->engine(), ::fallbackImportPaths());

    view->setSource(source);

    view->show();

    int result = application->exec();

    delete view;
    delete application;

    return result;
}
