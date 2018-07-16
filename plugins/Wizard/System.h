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

public:
    System();
    ~System() = default;

    /**
     * Checks whether the wizard is enabled for first-run or otherwise
     */
    bool wizardEnabled() const;

    /**
     * Returns the update version(s) that the wizard has not yet run for.
     * Will be empty if the current wizard version is the same version that has
     * already run or if the OOBE (first-time) wizard is set to run.
     * The special value [QVersionNumber(0)] denotes that the first-time setup
     * should run.
     * The special value [] denotes that the wizard should not be run.
     */
    std::vector<QVersionNumber> versionsToShow() const;

    /**
     * Returns the possible update versions
     */
    std::vector<QVersionNumber> wizardUpdates() const
    {
        // Add a new QVersionNumber to this array for every new set of pages you
        // would like to add to the wizard. The wizard will check for every
        // version between its last run and its current version (::currentVersion())
        return {
            QVersionNumber(1, 0, 0)
        };
    }

    /**
     * The update version for the Wizard in this version of Unity8. Bump this
     * version and add your new value to ::wizardUpdates(), then set the
     * showOnVersions property for the pages you would like to run on the current
     * update to the new value.
     */
    QVersionNumber currentVersion() const
    {
        return QVersionNumber(1, 0, 0);
    }

    /**
     * Set that the OOBE (first-run) wizard should be run
     */
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
