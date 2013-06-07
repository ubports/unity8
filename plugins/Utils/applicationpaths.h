/*
 * Copyright (C) 2013 Canonical, Ltd.
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
 *
 * Authored by: Nick Dedekind <nick.dedekind@canonical.com>
 */


#ifndef APPLICATION_PATHS_H
#define APPLICATION_PATHS_H

#include <QObject>
#include "paths.h"

class ApplicationPaths : public QObject
{
    Q_OBJECT
public:
    ApplicationPaths(QObject*parent=0):QObject(parent) {}

    Q_INVOKABLE bool isRunningInstalled() const     { return ::isRunningInstalled(); }
    Q_INVOKABLE QString shellAppDirectory() const   { return ::shellAppDirectory(); }
    Q_INVOKABLE QString shellImportPath() const     { return ::shellImportPath(); }
    Q_INVOKABLE QString fakePluginsImportPath() const { return ::fakePluginsImportPath(); }
    Q_INVOKABLE QStringList shellDataDirs() const   { return ::shellDataDirs(); }
    Q_INVOKABLE QString sourceDirectory() const     { return ::sourceDirectory(); }
};

#endif // APPLICATION_PATHS_H
