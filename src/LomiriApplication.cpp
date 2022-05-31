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

#include "LomiriApplication.h"

// Qt
#include <QLibrary>
#include <QProcess>
#include <QScreen>
#include <QQmlContext>
#include <QQmlComponent>

#include <QGSettings>

#include <libintl.h>

// qtmir
#include <qtmir/displayconfigurationstorage.h>

// local
#include <paths.h>
#include "CachingNetworkManagerFactory.h"
#include "LomiriCommandLineParser.h"
#include "DebuggingController.h"
#include "WindowManagementPolicy.h"
#include "DisplayConfigurationStorage.h"

#include <QDebug>



LomiriApplication::LomiriApplication(int & argc, char ** argv)
    : qtmir::MirServerApplication(argc, argv, { qtmir::SetWindowManagementPolicy<WindowManagementPolicy>(),
                                                qtmir::SetDisplayConfigurationStorage<DisplayConfigurationStorage>() })
    , m_qmlArgs(this)
{
    setApplicationName(QStringLiteral("lomiri"));
    setOrganizationName(QStringLiteral("Canonical"));

    setupQmlEngine();

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

    bindtextdomain("lomiri", translationDirectory().toUtf8().data());
    textdomain("lomiri");

    QScopedPointer<QGSettings> gSettings(new QGSettings("com.lomiri.Shell"));
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

    auto component(new QQmlComponent(m_qmlEngine, m_qmlArgs.qmlfie()));
    component->create();
    if (component->status() == QQmlComponent::Error) {
        qDebug().nospace().noquote() \
            << "Lomiri encountered an unrecoverable error while loading:\n"
            << component->errorString();
        m_qmlEngine->rootContext()->setContextProperty(QStringLiteral("errorString"), component->errorString());
        auto errorComponent(new QQmlComponent(m_qmlEngine,
                                         QUrl::fromLocalFile(::qmlDirectory() + "/ErrorApplication.qml")));
        errorComponent->create();
        if (!errorComponent->errorString().isEmpty())
            qDebug().nospace().noquote() \
                << "Lomiri encountered an error while loading the error screen:\n"
                << errorComponent->errorString();
        return;
    }

    #ifdef LOMIRI_ENABLE_TOUCH_EMULATION
    // You will need this if you want to interact with touch-only components using a mouse
    // Needed only when manually testing on a desktop.
    if (m_qmlArgs.hasMouseToTouch()) {
        m_mouseTouchAdaptor = MouseTouchAdaptor::instance();
    }
    #endif
}

LomiriApplication::~LomiriApplication()
{
    destroyResources();
}

void LomiriApplication::destroyResources()
{
    #ifdef LOMIRI_ENABLE_TOUCH_EMULATION
    delete m_mouseTouchAdaptor;
    m_mouseTouchAdaptor = nullptr;
    #endif

    delete m_qmlEngine;
    m_qmlEngine = nullptr;
}

void LomiriApplication::setupQmlEngine()
{
    m_qmlEngine = new QQmlEngine(this);

    m_qmlEngine->setBaseUrl(QUrl::fromLocalFile(::qmlDirectory()));

    prependImportPaths(m_qmlEngine, ::overrideImportPaths());
    appendImportPaths(m_qmlEngine, ::fallbackImportPaths());

    m_qmlEngine->setNetworkAccessManagerFactory(new CachingNetworkManagerFactory);

    QObject::connect(m_qmlEngine, &QQmlEngine::quit, this, &QGuiApplication::quit);
}
