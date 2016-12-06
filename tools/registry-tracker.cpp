/*
 * Copyright (C) 2013 Canonical, Ltd.
 *
 * Authors:
 *  Michal Hruby <michal.hruby@canonical.com>
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
#include <QtGlobal>
#include <QDir>

// local
#include "registry-tracker.h"


RegistryTracker::RegistryTracker(QStringList const& scopes, bool systemScopes, bool serverScopes):
    m_scopes(scopes),
    m_systemScopes(systemScopes),
    m_serverScopes(serverScopes),
    m_registry(nullptr),
    m_endpoints_dir(QDir::temp().filePath("scope-dev-endpoints.XXXXXX"))
{
    runRegistry();
}

RegistryTracker::~RegistryTracker()
{
    if (m_registry.state() != QProcess::NotRunning) {
        m_registry.terminate();
        m_registry.waitForFinished(5000);
        m_registry.kill();
    }
}

#define RUNTIME_CONFIG \
"[Runtime]\n" \
"Registry.Identity = Registry\n" \
"Registry.ConfigFile = %1\n" \
"Default.Middleware = Zmq\n" \
"Zmq.ConfigFile = %2\n" \
"Smartscopes.Registry.Identity = %3\n"

#define REGISTRY_CONFIG \
"[Registry]\n" \
"Middleware = Zmq\n" \
"Zmq.ConfigFile = %1\n" \
"Scope.InstallDir = %2\n" \
"Scoperunner.Path = %3\n"

#define MW_CONFIG \
"[Zmq]\n" \
"EndpointDir = %1\n"

void RegistryTracker::runRegistry()
{
    QDir tmp(QDir::temp());
    m_runtime_config.setFileTemplate(tmp.filePath("Runtime.XXXXXX.ini"));
    m_registry_config.setFileTemplate(tmp.filePath("Registry.XXXXXX.ini"));
    m_mw_config.setFileTemplate(tmp.filePath("Zmq.XXXXXX.ini"));

    if (!m_runtime_config.open() || !m_registry_config.open() || !m_mw_config.open() || !m_endpoints_dir.isValid()) {
        qWarning("Unable to open temporary files!");
        return;
    }

    // FIXME At the moment we use pkg-config but ideally the library
    // would just have a function that returns these values
    QString scopeInstallDir;
    QString scopeRegistryBin;
    QString scopeRunnerBin;
    {
        QProcess pkg_config;
        QByteArray output;
        QStringList arguments;
        arguments << "--variable=scopesdir";
        arguments << "libunity-scopes";
        pkg_config.start("pkg-config", arguments);
        pkg_config.waitForFinished();
        output = pkg_config.readAllStandardOutput();
        scopeInstallDir = QDir(QString::fromLocal8Bit(output)).path().trimmed();

        arguments[0] = "--variable=scoperegistry_bin";
        pkg_config.start("pkg-config", arguments);
        pkg_config.waitForFinished();
        output = pkg_config.readAllStandardOutput();
        scopeRegistryBin = QString::fromLocal8Bit(output).trimmed();

        arguments[0] = "--variable=scoperunner_bin";
        pkg_config.start("pkg-config", arguments);
        pkg_config.waitForFinished();
        output = pkg_config.readAllStandardOutput();
        scopeRunnerBin = QString::fromLocal8Bit(output).trimmed();
    }

    if (scopeInstallDir.isEmpty() || scopeRegistryBin.isEmpty() || scopeRunnerBin.isEmpty()) {
        qWarning("Unable to find libunity-scopes package config file");
        return;
    }

    // FIXME: keep in sync with the SSRegistry config
    QString runtime_ini = QString(RUNTIME_CONFIG).arg(m_registry_config.fileName(), m_mw_config.fileName(), m_serverScopes ? "SSRegistry" : "");
    if (!m_systemScopes) {
        m_scopeInstallDir.reset(new QTemporaryDir(tmp.filePath("scopes.XXXXXX")));
        if (!m_scopeInstallDir->isValid()) {
            qWarning("Unable to create temporary scopes directory!");
        }
        scopeInstallDir = m_scopeInstallDir->path();
    }
    QString registry_ini = QString(REGISTRY_CONFIG).arg(m_mw_config.fileName(), scopeInstallDir, scopeRunnerBin);
    QString mw_ini = QString(MW_CONFIG).arg(m_endpoints_dir.path());

    if (!m_systemScopes) {
        // Disable OEM and Click scopes when system scopes are disabled
        registry_ini += "OEM.InstallDir = /unused\n";
        registry_ini += "Click.InstallDir = /unused\n";
    }

    m_runtime_config.write(runtime_ini.toUtf8());
    m_registry_config.write(registry_ini.toUtf8());
    m_mw_config.write(mw_ini.toUtf8());

    m_runtime_config.flush();
    m_registry_config.flush();
    m_mw_config.flush();

    qputenv("UNITY_SCOPES_RUNTIME_PATH", m_runtime_config.fileName().toLocal8Bit());

    QStringList arguments;
    arguments << m_runtime_config.fileName();
    arguments << m_scopes;

    m_registry.setProcessChannelMode(QProcess::ForwardedChannels);
    m_registry.start(scopeRegistryBin, arguments);
}
