/*
 * This file is part of system-settings
 *
 * Copyright (C) 2014 Canonical Ltd.
 *
 * This program is free software: you can redistribute it and/or modify it
 * under the terms of the GNU General Public License version 3, as published
 * by the Free Software Foundation.
 *
 * This program is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY; without even the implied warranties of
 * MERCHANTABILITY, SATISFACTORY QUALITY, or FITNESS FOR A PARTICULAR
 * PURPOSE.  See the GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License along
 * with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

#include <csignal>
#include <libintl.h>
#include <qpa/qplatformnativeinterface.h>
#include <QDebug>
#include <QGuiApplication>
#include <QLibrary>
#include <QObject>
#include <QProcess>
#include <QQmlContext>
#include <QQmlEngine>
#include <QQuickItem>
#include <QQuickView>
#include <QTimer>

#include "PageList.h"

void handleQuit()
{
    QProcess::startDetached("initctl start ubuntu-system-settings-wizard-cleanup");
}

int main(int argc, const char *argv[])
{
    bool isMirServer = false;
    if (qgetenv("QT_QPA_PLATFORM") == "ubuntumirclient") {
        setenv("QT_QPA_PLATFORM", "mirserver", 1 /* overwrite */);
        isMirServer = true;
    }

    QGuiApplication::setApplicationName("System Settings Wizard");
    QGuiApplication *application = new QGuiApplication(argc, (char**)argv);

    bindtextdomain(I18N_DOMAIN, NULL);
    textdomain(I18N_DOMAIN);

    QQuickView* view = new QQuickView();
    view->setResizeMode(QQuickView::SizeRootObjectToView);
    view->setTitle("Welcome Wizard");

    QString rootDir = qgetenv("UBUNTU_SYSTEM_SETTINGS_WIZARD_ROOT"); // for testing
    if (rootDir.isEmpty())
        rootDir = WIZARD_ROOT;

    QString modulesDir = qgetenv("UBUNTU_SYSTEM_SETTINGS_WIZARD_MODULES"); // for testing
    if (modulesDir.isEmpty())
        modulesDir = PLUGIN_PRIVATE_MODULE_DIR;

    if (!isMirServer) {
        view->engine()->addImportPath(modulesDir + "/Ubuntu/SystemSettings/Wizard/NonMir");
    }
    view->engine()->addImportPath(modulesDir);
    view->engine()->addImportPath(PLUGIN_QML_DIR);
    view->engine()->addImportPath(SHELL_PLUGINDIR);

    PageList pageList;
    view->rootContext()->setContextProperty("pageList", &pageList);
    view->setSource(QUrl(rootDir + "/ubuntu/settings/wizard/qml/main.qml"));
    view->setColor("transparent");

    QObject::connect(view->engine(), &QQmlEngine::quit, handleQuit);

    if (isMirServer) {
        view->showFullScreen();
    } else {
        view->show();
    }

    int result = application->exec();

    delete view;
    delete application;
    return result;
}

#include "main.moc"
