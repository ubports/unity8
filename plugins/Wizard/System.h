/*
 * Copyright (C) 2014-2016 Canonical Ltd.
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
#include <QVersionNumber>
#include <QObject>
#include <QString>

class System : public QObject
{
    Q_OBJECT
    Q_PROPERTY(bool wizardEnabled READ wizardEnabled WRITE setWizardEnabled NOTIFY wizardEnabledChanged)
    Q_PROPERTY(int versionToShow READ versionToShow)

public:
    System();
    ~System() = default;

    /**
     * Checks whether the wizard is enabled for first-run or otherwise.
     */
    bool wizardEnabled() const;

    /**
     * Returns the version of the wizard that should be run
     * -1 denotes that no wizard should be run. 0 denotes that the first-run
     * wizard should be run. If we determine that the first-run wizard has run
     * but ::CURRENT_VERSION has not, we return ::CURRENT_VERSION.
     * For example, if ::CURRENT_VERSION is 4, version 4 has not run, but the
     * first-run wizard has run, this method will return 4
     */
    signed int versionToShow() const;

    /**
     * The update version for the Wizard in this version of Unity8. Bump this
     * version then set the showOnVersions property for the pages you would like
     * to run on the current update to the new value.
     */
    int CURRENT_VERSION = 1;

    void setWizardEnabled(bool enabled);

public Q_SLOTS:
    void updateSessionLocale(const QString &locale);
    /**
     * Mark the wizard to skip all the pages and just show the last (welcome to ubuntu) page
     */
    void skipUntilFinishedPage();

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
