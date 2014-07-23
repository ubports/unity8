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

// Qt
//#include <QCommandLineParser>
#include <QtQuick/QQuickView>
#include <QtGui/QGuiApplication>
#include <QtQml/QQmlEngine>
#include <QtQml/QQmlContext>
//#include <qpa/qplatformnativeinterface.h>
//#include <QLibrary>
#include <QDebug>
//#include <libintl.h>
//#include <dlfcn.h>
//#include <csignal>

//// local
#include <paths.h>
//#include "MouseTouchAdaptor.h"
//#include "ApplicationArguments.h"

//#include <unity-mir/qmirserver.h>


int main(int argc, const char *argv[])
{
    QGuiApplication *application = new QGuiApplication(argc, (char**)argv);

    QQuickView* view = new QQuickView();
    view->setResizeMode(QQuickView::SizeRootObjectToView);
    view->setTitle("Unity Dash");
//    view->engine()->setBaseUrl(QUrl::fromLocalFile(::qmlDirectory()));
//    view->rootContext()->setContextProperty("applicationArguments", &qmlArgs);

    QUrl source(::qmlDirectory()+"Dash/DashApplication.qml");
    prependImportPaths(view->engine(), ::overrideImportPaths());
    appendImportPaths(view->engine(), ::fallbackImportPaths());

    view->setSource(source);
    view->show();

    int result = application->exec();

    qDebug() << "fooooooooooo" << result;

    delete view;
    delete application;

    return result;
}
