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

#include "SystemImage.h"

#define SYSTEMIMAGE_SERVICE QStringLiteral("com.canonical.SystemImage")
#define SYSTEMIMAGE_PATH QStringLiteral("/Service")
#define SYSTEMIMAGE_IFACE QStringLiteral("com.canonical.SystemImage")

SystemImage::SystemImage(QObject *parent)
    : QObject(parent)
{
    QDBusConnection::systemBus().connect(SYSTEMIMAGE_SERVICE, SYSTEMIMAGE_PATH, SYSTEMIMAGE_IFACE, QStringLiteral("UpdateAvailableStatus"),
                                         this, SLOT(onUpdateAvailableStatus(bool,bool,QString,int,QString,QString)));
    QDBusConnection::systemBus().connect(SYSTEMIMAGE_SERVICE, SYSTEMIMAGE_PATH, SYSTEMIMAGE_IFACE, QStringLiteral("UpdateDownloaded"),
                                         this, SLOT(onUpdateDownloaded(bool)));
    QDBusConnection::systemBus().connect(SYSTEMIMAGE_SERVICE, SYSTEMIMAGE_PATH, SYSTEMIMAGE_IFACE, QStringLiteral("UpdateFailed"),
                                         this, SLOT(onUpdateFailed(int,QString)));
    QDBusConnection::systemBus().connect(SYSTEMIMAGE_SERVICE, SYSTEMIMAGE_PATH, SYSTEMIMAGE_IFACE, QStringLiteral("Applied"),
                                         this, SLOT(onUpdateApplied(bool)));
}

void SystemImage::checkForUpdate()
{
    const QDBusMessage msg = QDBusMessage::createMethodCall(SYSTEMIMAGE_SERVICE, SYSTEMIMAGE_PATH, SYSTEMIMAGE_IFACE,
                                                            QStringLiteral("CheckForUpdate"));
    QDBusConnection::systemBus().asyncCall(msg);
}

void SystemImage::applyUpdate()
{
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
    qDebug() << Q_FUNC_INFO << "A new update is" << (is_available ? "" : "NOT") << "available";

    if (is_available == m_updateAvailable) {
        return;
    }

    m_updateAvailable = is_available;
    m_downloading = downloading;
    m_availableVersion = available_version;
    m_updateSize = update_size;
    m_lastUpdateDate = last_update_date;
    m_errorReason = error_reason;
    Q_EMIT updateAvailableStatus();
}

void SystemImage::onUpdateDownloaded(bool downloaded)
{
    if (downloaded != m_downloaded) {
        m_downloaded = downloaded;
        Q_EMIT updateDownloadedChanged();
    }
}

void SystemImage::onUpdateFailed(int consecutive_failure_count, const QString &last_reason)
{
    Q_UNUSED(consecutive_failure_count)
    qWarning() << Q_FUNC_INFO << "System Update failed:" << last_reason;
}

void SystemImage::onUpdateApplied(bool applied)
{
    qDebug() << Q_FUNC_INFO << "System Update applied with status:" << applied;
    if (applied) {
        resetUpdateStatus();
        Q_EMIT updateAvailableStatus();
    }
}

void SystemImage::resetUpdateStatus()
{
    m_updateAvailable = false;
    m_downloading = false;
    m_downloaded = false;
    m_availableVersion.clear();
    m_updateSize = -1;
    m_lastUpdateDate.clear();
    m_errorReason.clear();
}
