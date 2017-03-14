/*
 * Copyright (C) 2017 Canonical, Ltd.
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
#include <QDebug>
#include <QCommandLineParser>
#include <QGuiApplication>
#include <QQmlContext>
#include <QQmlEngine>
#include <QQuickView>

// local
#include <paths.h>

int main(int argc, char *argv[])
{
    QGuiApplication::setApplicationName("Menu Test Tool");
    QGuiApplication *application = new QGuiApplication(argc, argv);

    QCommandLineParser parser;
    parser.parse(application->arguments());
    const QStringList args = parser.positionalArguments();

    if (args.count() != 1) {
        qWarning() << "You need to pass the dbus address";
        return 1;
    }

    QQuickView* view = new QQuickView();
    view->setResizeMode(QQuickView::SizeRootObjectToView);
    view->setTitle(QGuiApplication::applicationName());
    view->engine()->setBaseUrl(QUrl::fromLocalFile(::qmlDirectory()));
    view->rootContext()->setContextProperty("contextBusName", args[0]);

    QUrl source(::sourceDirectory() + "/tools/menutool/menutool.qml");
    prependImportPaths(view->engine(), ::overrideImportPaths());
    prependImportPaths(view->engine(), ::nonMirImportPaths());

    view->setSource(source);

    view->show();

    int result = application->exec();

    delete view;
    delete application;

    return result;
}
