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

#include <libintl.h>

// libandroid-properties
#include <hybris/properties/properties.h>

// local
#include <paths.h>
#include "CachingNetworkManagerFactory.h"
#include "UnityCommandLineParser.h"
#include "DebuggingController.h"

#include <QDebug>

#include <qtmir/windowmanagementpolicy.h>

class WindowManagementPolicy : public qtmir::WindowManagementPolicy
{
public:
    WindowManagementPolicy(const miral::WindowManagerTools &tools, qtmir::WindowManagementPolicyPrivate& dd)
        : qtmir::WindowManagementPolicy(tools, dd)
    {}

//    virtual void advise_adding_to_workspace(
//        std::shared_ptr<miral::Workspace> const& workspace,
//        std::vector<miral::Window> const& windows) override
//    {
//    }

//    virtual void advise_removing_from_workspace(
//        std::shared_ptr<miral::Workspace> const& workspace,
//        std::vector<miral::Window> const& windows) override
//    {
//    }
};


ShellApplication::ShellApplication(int & argc, char ** argv)
    : qtmir::MirServerApplication(argc, argv, {})
    , m_qmlArgs(this)
{
    setApplicationName(QStringLiteral("unity8"));
    setOrganizationName(QStringLiteral("Canonical"));

    setupQmlEngine();

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

    m_qmlEngine->rootContext()->setContextProperty(QStringLiteral("applicationArguments"), &m_qmlArgs);
    m_qmlEngine->rootContext()->setContextProperty("DebuggingController", new DebuggingController(this));

    QByteArray pxpguEnv = qgetenv("GRID_UNIT_PX");
    bool ok;
    int pxpgu = pxpguEnv.toInt(&ok);
    if (!ok) {
        pxpgu = 8;
    }
    m_qmlEngine->rootContext()->setContextProperty("internalGu", pxpgu);
    m_qmlEngine->load(::qmlDirectory() + "/ShellApplication.qml");

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

void ShellApplication::setupQmlEngine()
{
    m_qmlEngine = new QQmlApplicationEngine(this);

    m_qmlEngine->setBaseUrl(QUrl::fromLocalFile(::qmlDirectory()));

    prependImportPaths(m_qmlEngine, ::overrideImportPaths());
    appendImportPaths(m_qmlEngine, ::fallbackImportPaths());

    m_qmlEngine->setNetworkAccessManagerFactory(new CachingNetworkManagerFactory);

    QObject::connect(m_qmlEngine, &QQmlEngine::quit, this, &QGuiApplication::quit);
}
