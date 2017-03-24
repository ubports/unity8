/*
 * Copyright (C) 2015 Canonical, Ltd.
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

#include "ShellApplication.h"

// Qt
#include <QLibrary>
#include <QProcess>
#include <QScreen>
#include <QQmlContext>
#include <QQmlComponent>

#include <QGSettings>

#include <libintl.h>

// libandroid-properties
#include <hybris/properties/properties.h>

// local
#include <paths.h>
#include "CachingNetworkManagerFactory.h"
#include "UnityCommandLineParser.h"
#include "DebuggingController.h"

ShellApplication::ShellApplication(int & argc, char ** argv, bool isMirServer)
    : QGuiApplication(argc, argv)
    , m_qmlArgs(this)
{
    setApplicationName(QStringLiteral("unity8"));
    setOrganizationName(QStringLiteral("Canonical"));

    setupQmlEngine(isMirServer);

    if (m_qmlArgs.deviceName().isEmpty()) {
        char buffer[200];
        property_get("ro.product.device", buffer /* value */, "desktop" /* default_value*/);
        m_qmlArgs.setDeviceName(QString(buffer));
    }

    // The testability driver is only loaded by QApplication but not by QGuiApplication.
    // However, QApplication depends on QWidget which would add some unneeded overhead => Let's load the testability driver on our own.
    if (m_qmlArgs.hasTestability() || getenv("QT_LOAD_TESTABILITY")) {
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

    QScopedPointer<QGSettings> gSettings(new QGSettings("com.canonical.Unity8"));
    gSettings->reset(QStringLiteral("alwaysShowOsk"));


    QByteArray pxpguEnv = qgetenv("GRID_UNIT_PX");
    bool ok;
    int pxpgu = pxpguEnv.toInt(&ok);
    if (!ok) {
        pxpgu = 8;
    }
    m_qmlEngine->rootContext()->setContextProperty("internalGu", pxpgu);
    m_qmlEngine->rootContext()->setContextProperty(QStringLiteral("applicationArguments"), &m_qmlArgs);
    m_qmlEngine->rootContext()->setContextProperty("DebuggingController", new DebuggingController(this));

    auto component(new QQmlComponent(m_qmlEngine,
                                     QUrl::fromLocalFile(::qmlDirectory() + "/ShellApplication.qml")));
    component->create();
    if (component->status() == QQmlComponent::Error) {
        m_qmlEngine->rootContext()->setContextProperty(QStringLiteral("errorString"), component->errorString());
        auto errorComponent(new QQmlComponent(m_qmlEngine,
                                         QUrl::fromLocalFile(::qmlDirectory() + "/ErrorApplication.qml")));
        errorComponent->create();
        qDebug() << errorComponent->errorString();
        return;
    }

    #ifdef UNITY8_ENABLE_TOUCH_EMULATION
    // You will need this if you want to interact with touch-only components using a mouse
    // Needed only when manually testing on a desktop.
    if (m_qmlArgs.hasMouseToTouch()) {
        m_mouseTouchAdaptor = MouseTouchAdaptor::instance();
    }
    #endif

    if (m_qmlArgs.mode().compare("greeter") == 0) {
        if (!QProcess::startDetached("initctl emit --no-wait unity8-greeter-started")) {
            qDebug() << "Unable to send unity8-greeter-started event to Upstart";
        }
    }
}

ShellApplication::~ShellApplication()
{
    destroyResources();
}

void ShellApplication::destroyResources()
{
    #ifdef UNITY8_ENABLE_TOUCH_EMULATION
    delete m_mouseTouchAdaptor;
    m_mouseTouchAdaptor = nullptr;
    #endif

    delete m_qmlEngine;
    m_qmlEngine = nullptr;
}

void ShellApplication::setupQmlEngine(bool isMirServer)
{
    m_qmlEngine = new QQmlEngine(this);

    m_qmlEngine->setBaseUrl(QUrl::fromLocalFile(::qmlDirectory()));

    prependImportPaths(m_qmlEngine, ::overrideImportPaths());
    if (!isMirServer) {
        prependImportPaths(m_qmlEngine, ::nonMirImportPaths());
    }
    appendImportPaths(m_qmlEngine, ::fallbackImportPaths());

    m_qmlEngine->setNetworkAccessManagerFactory(new CachingNetworkManagerFactory);

    QObject::connect(m_qmlEngine, &QQmlEngine::quit, this, &QGuiApplication::quit);
}
