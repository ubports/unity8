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
    Q_PROPERTY(QString version READ version NOTIFY versionChanged)
    Q_PROPERTY(bool isUpdate READ isUpdate NOTIFY isUpdateChanged)

public:
    System();
    ~System() = default;

    /**
     * Checks whether the wizard is enabled for first-run or otherwise.
     */
    bool wizardEnabled() const;

    QString version() const;
    bool isUpdate() const;

    void setWizardEnabled(bool enabled);

public Q_SLOTS:
    void updateSessionLocale(const QString &locale);
    /**
     * Mark the wizard to skip all the pages and just show the last (welcome to ubuntu) page
     */
    void skipUntilFinishedPage();

Q_SIGNALS:
    void wizardEnabledChanged();
    void versionChanged();
    void isUpdateChanged();

private Q_SLOTS:
    void watcherFileChanged();

private:
    Q_DISABLE_COPY(System)

    static QString wizardEnabledPath();
    static QString currentFrameworkPath();
    static void setSessionVariable(const QString &variable, const QString &value);
    static QString readCurrentFramework();
    static QString readWizardEnabled();

    QFileSystemWatcher m_fsWatcher;
};

#endif
