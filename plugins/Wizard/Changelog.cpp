/*
 * Copyright (C) 2018 The UBports project
 * Written by: Marius Gripsgard <marius@ubports.com>
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

#include "Changelog.h"

#include <QDir>
#include <QFile>
#include <QTextStream>

Changelog::Changelog()
    : QObject()
{
    readChangelog();
    if(QFile::exists(changelogPath()))
        m_fsWatcher.addPath(changelogPath());
    connect(&m_fsWatcher, &QFileSystemWatcher::fileChanged, this, &Changelog::watcherFileChanged);
}

QString Changelog::changelogPath()
{
    return "/usr/share/ubports/changelogs/current";
}

QString Changelog::text() const
{
    return m_text;
}

void Changelog::readChangelog()
{
    if(!QFile::exists(changelogPath()))
      return;
    QFile f(changelogPath());
    if (!f.open(QFile::ReadOnly | QFile::Text)) return;
    QTextStream in(&f);
    m_text = in.readAll();
    Q_EMIT textChanged();
}

void Changelog::watcherFileChanged()
{
    readChangelog();
    m_fsWatcher.removePath(changelogPath());
}
