/*
 * Copyright (C) 2014-2016 Canonical, Ltd.
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

#include <QDBusConnection>
#include <QDBusPendingCall>
#include <QDBusReply>
#include <QDebug>

#include <glib.h>

#include "SystemImage.h"

#define SYSTEMIMAGE_SERVICE QStringLiteral("com.canonical.SystemImage")
#define SYSTEMIMAGE_PATH QStringLiteral("/Service")
#define SYSTEMIMAGE_IFACE QStringLiteral("com.canonical.SystemImage")

Q_LOGGING_CATEGORY(SYSTEMIMAGEPLUGIN, "unity8.systemimage", QtWarningMsg)

#define DEBUG_MSG qCDebug(SYSTEMIMAGEPLUGIN).nospace().noquote() << Q_FUNC_INFO
#define WARNING_MSG qCWarning(SYSTEMIMAGEPLUGIN).nospace().noquote() << Q_FUNC_INFO

SystemImage::SystemImage(QObject *parent)
    : QObject(parent)
{
    QDBusConnection::systemBus().connect(SYSTEMIMAGE_SERVICE, SYSTEMIMAGE_PATH, SYSTEMIMAGE_IFACE, QStringLiteral("UpdateAvailableStatus"),
                                         this, SLOT(onUpdateAvailableStatus(bool,bool,QString,int,QString,QString)));
    QDBusConnection::systemBus().connect(SYSTEMIMAGE_SERVICE, SYSTEMIMAGE_PATH, SYSTEMIMAGE_IFACE, QStringLiteral("UpdateDownloaded"),
                                         this, SLOT(onUpdateDownloaded()));
    QDBusConnection::systemBus().connect(SYSTEMIMAGE_SERVICE, SYSTEMIMAGE_PATH, SYSTEMIMAGE_IFACE, QStringLiteral("UpdateFailed"),
                                         this, SLOT(onUpdateFailed(int,QString)));
    QDBusConnection::systemBus().connect(SYSTEMIMAGE_SERVICE, SYSTEMIMAGE_PATH, SYSTEMIMAGE_IFACE, QStringLiteral("Applied"),
                                         this, SLOT(onUpdateApplied(bool)));
    QDBusConnection::systemBus().connect(SYSTEMIMAGE_SERVICE, SYSTEMIMAGE_PATH, SYSTEMIMAGE_IFACE, QStringLiteral("Rebooting"),
                                         this, SLOT(onRebooting(bool)));
}

void SystemImage::checkForUpdate()
{
    DEBUG_MSG << "Checking for update";
    const QDBusMessage msg = QDBusMessage::createMethodCall(SYSTEMIMAGE_SERVICE, SYSTEMIMAGE_PATH, SYSTEMIMAGE_IFACE,
                                                            QStringLiteral("CheckForUpdate"));
    QDBusConnection::systemBus().asyncCall(msg);
}

void SystemImage::applyUpdate()
{
    DEBUG_MSG << "Applying update";
    setUpdateApplying(true);

    const QDBusMessage msg = QDBusMessage::createMethodCall(SYSTEMIMAGE_SERVICE, SYSTEMIMAGE_PATH, SYSTEMIMAGE_IFACE,
                                                            QStringLiteral("ApplyUpdate"));
    QDBusConnection::systemBus().asyncCall(msg);
}

void SystemImage::factoryReset()
{
    const QDBusMessage msg = QDBusMessage::createMethodCall(SYSTEMIMAGE_SERVICE, SYSTEMIMAGE_PATH, SYSTEMIMAGE_IFACE,
                                                            QStringLiteral("FactoryReset"));
    QDBusConnection::systemBus().asyncCall(msg);
}

void SystemImage::onUpdateAvailableStatus(bool is_available, bool downloading, const QString &available_version, int update_size,
                                          const QString &last_update_date, const QString &error_reason)
{
    DEBUG_MSG << "A new update is " << (is_available ? "" : "NOT") << "available";

    if (is_available == m_updateAvailable) {
        return;
    }

    m_updateAvailable = is_available;
    m_downloading = downloading;
    m_availableVersion = available_version;
    m_updateSize = formatSize(update_size);
    m_lastUpdateDate = last_update_date;
    m_errorReason = error_reason;
    Q_EMIT updateAvailableStatus();

    DEBUG_MSG << "Downloading: " << downloading << ", version: " << available_version << ", last update: " << last_update_date <<
                ", size: " << m_updateSize;
}

void SystemImage::onUpdateDownloaded()
{
    DEBUG_MSG << "Update downloaded";

    m_downloaded = true;
    Q_EMIT updateDownloadedChanged();
}

void SystemImage::onUpdateFailed(int /*consecutive_failure_count*/, const QString &last_reason)
{
    WARNING_MSG << "System Update failed: " << last_reason;
    setUpdateApplying(false);
}

void SystemImage::onUpdateApplied(bool applied)
{
    DEBUG_MSG << "System Update applied with status: " << applied;
    setUpdateApplying(false);
    if (applied) {
        resetUpdateStatus();
        Q_EMIT updateAvailableStatus();
    }
}

void SystemImage::onRebooting(bool status)
{
    setUpdateApplying(false);
    DEBUG_MSG << "Rebooting: " << status;
}

void SystemImage::setUpdateApplying(bool status)
{
    if (status != m_updateApplying) {
        m_updateApplying = status;
        Q_EMIT updateApplyingChanged();
    }
}

void SystemImage::resetUpdateStatus()
{
    m_updateAvailable = false;
    m_updateApplying = false;
    m_downloading = false;
    m_downloaded = false;
    m_availableVersion.clear();
    m_updateSize.clear();
    m_lastUpdateDate.clear();
    m_errorReason.clear();
}

QString SystemImage::formatSize(quint64 size) const
{
    guint64 g_size = size;

    gchar * formatted_size = g_format_size(g_size);
    QString q_formatted_size = QString::fromLocal8Bit(formatted_size);
    g_free(formatted_size);

    return q_formatted_size;
}
