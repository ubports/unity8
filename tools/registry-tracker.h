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
#include <QProcess>
#include <QTemporaryFile>
#include <QTemporaryDir>
#include <QDebug>


class RegistryTracker
{
public:
    RegistryTracker(QString const&);
    ~RegistryTracker();

    QProcess* registry() const;

private:
    void runRegistry();

    QString m_scopeDir;
    QProcess m_registry;
    QTemporaryDir m_endpoints_dir;
    QTemporaryFile m_runtime_config;
    QTemporaryFile m_registry_config;
    QTemporaryFile m_mw_config;
};
