/*
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

#ifndef WIZARD_SYSTEM_H
#define WIZARD_SYSTEM_H

#include <QFileSystemWatcher>
#include <QObject>
#include <QString>

class System : public QObject
{
    Q_OBJECT
    Q_PROPERTY(bool wizardEnabled READ wizardEnabled WRITE setWizardEnabled NOTIFY wizardEnabledChanged)

public:
    System();

    bool wizardEnabled() const;
    void setWizardEnabled(bool enabled);

public Q_SLOTS:
    void updateSessionLanguage(const QString &locale);

Q_SIGNALS:
    void wizardEnabledChanged();

private Q_SLOTS:
    void watcherFileChanged();

private:
    Q_DISABLE_COPY(System)

    static QString wizardEnabledPath();
    static void setSessionVariable(const QString &variable, const QString &value);

    QFileSystemWatcher m_fsWatcher;
};

#endif
