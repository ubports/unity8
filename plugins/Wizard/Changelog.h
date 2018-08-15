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

#ifndef WIZARD_CHANGELOG_H
#define WIZARD_CHANGELOG_H

#include <QFileSystemWatcher>
#include <QObject>
#include <QString>

class Changelog : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString text READ text NOTIFY textChanged)

public:
    Changelog();
    ~Changelog() = default;

    QString text() const;

Q_SIGNALS:
    void textChanged();

private Q_SLOTS:
    void watcherFileChanged();

private:
    Q_DISABLE_COPY(Changelog)

    static QString changelogPath();
    void readChangelog();

    QFileSystemWatcher m_fsWatcher;
    QString m_text;
};

#endif
