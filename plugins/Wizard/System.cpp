/*
 * Copyright (C) 2018 The UBports project
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

#include "System.h"

#include <QDBusPendingCall>
#include <QDBusMessage>
#include <QDBusConnection>
#include <QDBusMetaType>
#include <QDir>
#include <QFile>
#include <QLocale>
#include <QMap>
#include <QProcess>
#include <QDebug>
#include <QSettings>

System::System()
    : QObject()
{
    // Register the argument needed for UpdateActivationEnvironment below
    qDBusRegisterMetaType<QMap<QString,QString>>();

    if(!wizardEnabled()) {
        m_fsWatcher.addPath(wizardEnabledPath());
    }
    connect(&m_fsWatcher, &QFileSystemWatcher::fileChanged, this, &System::watcherFileChanged);
}

QString System::wizardEnabledPath()
{
    // Uses ubuntu-system-settings namespace for historic compatibility reasons
    return QDir::home().filePath(QStringLiteral(".config/ubuntu-system-settings/wizard-has-run"));
}

QString System::currentFrameworkPath()
{
    QFileInfo f("/usr/share/click/frameworks/current");
    return f.canonicalFilePath();
}

/*
wizardEnabled and isUpdate logic

if wizard-has-run does NOT exist == is new install
if wizard-has-run exists but does NOT match current framework == is update
if wizard-has-run exists but does match current framework == show no wizard
*/

bool System::wizardPathExists() {
  return QFile::exists(wizardEnabledPath());
}

bool System::wizardEnabled() const
{
    if (!wizardPathExists()) {
        return true;
    }
    return isUpdate();
}

QString System::readCurrentFramework()
{
    QFile f(currentFrameworkPath());
    if (!f.open(QFile::ReadOnly | QFile::Text)) return "";
    QTextStream in(&f);
    return in.readAll();
}

QString System::readWizardEnabled()
{
    QFile f(wizardEnabledPath());
    if (!f.open(QFile::ReadOnly | QFile::Text)) return "";
    QTextStream in(&f);
    return in.readAll();
}

QString System::version() const
{
    return readCurrentFramework();
}

bool System::isUpdate() const
{
    if (!wizardPathExists()) {
        return false;
    }

    return readCurrentFramework() != readWizardEnabled();
}

void System::setWizardEnabled(bool enabled)
{
    if (wizardEnabled() == enabled && !isUpdate())
        return;

    if (enabled) {
        QFile::remove(wizardEnabledPath());
    } else {
        QDir(wizardEnabledPath()).mkpath(QStringLiteral(".."));
        if (QFile::exists(wizardEnabledPath())) {
            QFile::remove(wizardEnabledPath());
        }
        // For special cases check if wizardEnabledPath is a folder
        if (QDir(wizardEnabledPath()).exists()) {
            QDir(wizardEnabledPath()).removeRecursively();
        }
        QFile::copy(currentFrameworkPath(), wizardEnabledPath());
        m_fsWatcher.addPath(wizardEnabledPath());
        Q_EMIT wizardEnabledChanged();
        Q_EMIT isUpdateChanged();
    }
}

void System::watcherFileChanged()
{
    Q_EMIT wizardEnabledChanged();
    Q_EMIT isUpdateChanged();
    m_fsWatcher.removePath(wizardEnabledPath());
}

void System::setSessionVariable(const QString &variable, const QString &value)
{
    // We need to update both upstart's and DBus's environment
    QProcess::startDetached(QStringLiteral("initctl set-env --global %1=%2").arg(variable, value));

    QMap<QString,QString> valueMap;
    valueMap.insert(variable, value);

    QDBusMessage msg = QDBusMessage::createMethodCall(QStringLiteral("org.freedesktop.DBus"),
                                                      QStringLiteral("/org/freedesktop/DBus"),
                                                      QStringLiteral("org.freedesktop.DBus"),
                                                      QStringLiteral("UpdateActivationEnvironment"));

    msg << QVariant::fromValue(valueMap);
    QDBusConnection::sessionBus().asyncCall(msg);
}

void System::updateSessionLocale(const QString &locale)
{
    const QString language = locale.split(QStringLiteral("."))[0];

    setSessionVariable(QStringLiteral("LANGUAGE"), language);
    setSessionVariable(QStringLiteral("LANG"), locale);
    setSessionVariable(QStringLiteral("LC_ALL"), locale);

    // QLocale caches the default locale on startup, and Qt uses that cached
    // copy when formatting dates.  So manually update it here.
    QLocale::setDefault(QLocale(locale));

    // Restart bits of the session to pick up new language.
    QProcess::startDetached(QStringLiteral("sh -c \"initctl emit indicator-services-end; \
                                     initctl stop scope-registry; \
                                     initctl stop smart-scopes-proxy; \
                                     initctl emit --no-wait indicator-services-start; \
                                     initctl restart --no-wait ubuntu-location-service-trust-stored; \
                                     initctl restart --no-wait maliit-server; \
                                     initctl restart --no-wait indicator-messages; \
                                     initctl restart --no-wait unity8-dash\""));
}

void System::skipUntilFinishedPage()
{
    QSettings settings;
    settings.setValue(QStringLiteral("Wizard/SkipUntilFinishedPage"), true);
    settings.sync();
}
