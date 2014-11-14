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

#include "System.h"

#include <QDBusInterface>
#include <QDBusMetaType>
#include <QDir>
#include <QFile>
#include <QMap>
#include <QProcess>

System::System()
    : QObject(),
      m_fsWatcher()
{
    // Register the argument needed for UpdateActivationEnvironment below
    qDBusRegisterMetaType<QMap<QString,QString>>();

    m_fsWatcher.addPath(wizardEnabledPath());
    connect(&m_fsWatcher, SIGNAL(fileChanged(const QString &)),
            this, SIGNAL(wizardEnabledChanged()));
}

QString System::wizardEnabledPath()
{
    // Uses ubuntu-system-settings namespace for historic compatibility reasons
    return QDir::home().filePath(".config/ubuntu-system-settings/wizard-has-run");
}

bool System::wizardEnabled() const
{
    return !QFile::exists(wizardEnabledPath());
}

void System::setWizardEnabled(bool enabled)
{
    if (enabled) {
        QFile::remove(wizardEnabledPath());
    } else {
        QDir(wizardEnabledPath()).mkpath("..");
        QFile(wizardEnabledPath()).open(QIODevice::WriteOnly);
    }
}

void System::setSessionVariable(const QString &variable, const QString &value)
{
    // We need to update both upstart's and DBus's environment
    QProcess::execute(QString("initctl set-env --global %1=%2").arg(variable, value));

    QDBusInterface iface("org.freedesktop.DBus",
                         "/org/freedesktop/DBus",
                         "org.freedesktop.DBus",
                         QDBusConnection::sessionBus());

    QMap<QString,QString> valueMap;
    valueMap.insert(variable, value);
    iface.call("UpdateActivationEnvironment", QVariant::fromValue(valueMap));
}

void System::updateSessionLanguage(const QString &locale)
{
    QString language = locale.split(".")[0];

    setSessionVariable("LANGUAGE", language);
    setSessionVariable("LANG", locale);
    setSessionVariable("LC_ALL", locale);

    // Indicators and OSK need to pick up new language
    QProcess::startDetached("sh -c \"initctl emit indicator-services-end; \
                                     stop maliit-server; \
                                     initctl emit --no-wait indicator-services-start; \
                                     initctl start --no-wait maliit-server\"");
}
