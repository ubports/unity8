/*
 * Copyright (C) 2015 Canonical, Ltd.
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
 *
 */

#include "sessiongrabber.h"

#include <QDebug>
#include <QQuickItem>
#include <QQuickItemGrabResult>
#include <QtConcurrent>

static QString cacheFolder()
{
    return QStandardPaths::writableLocation(QStandardPaths::CacheLocation) + "/app_shots/";
}

static QString cachePath(const QString &appId)
{
    return cacheFolder() + appId + ".png";
}

SessionGrabber::SessionGrabber(QObject *parent)
    : QObject(parent)
    , m_target(nullptr)
    , m_watcher(nullptr)
{
}

QString SessionGrabber::appId() const
{
    return m_appId;
}

void SessionGrabber::setAppId(const QString &appId)
{
    if (appId != m_appId) {
        m_appId = appId;
        const QString path = cachePath(appId);
        if (QFile::exists(path)) {
            setPath(path);
        }
    }
}

QQuickItem *SessionGrabber::target() const
{
    return m_target;
}

void SessionGrabber::setTarget(QQuickItem *target)
{
    if (target != m_target) {
        m_target = target;
        Q_EMIT targetChanged();
    }
}

QString SessionGrabber::path() const
{
    return m_path;
}

void SessionGrabber::setPath(const QString &path)
{
    if (path != m_path) {
        m_path = path;
        Q_EMIT pathChanged();
    }
}

static QString saveScreenshot(const QString &appId, const QSharedPointer<QQuickItemGrabResult> grabResult)
{
    const QImage image = grabResult->image();
    const QString cPath = cacheFolder();
    QDir d;
    d.mkpath(cPath);
    const QString path = cachePath(appId);
    if (image.save(path)) {
        return path;
    } else {
        return QString();
    }
}

void SessionGrabber::grab()
{
    if (!m_grabResult.isNull()) {
        qWarning() << "Asked to grab a screenshot when there's one already being grabbed, ignoring";
        return;
    }

    if (m_target && !m_appId.isEmpty()) {
        // grabToImage runs in a separate thread
        m_grabResult = m_target->grabToImage();
        connect(m_grabResult.data(), &QQuickItemGrabResult::ready, this, &SessionGrabber::grabReady);
    } else {
        qWarning() << "Can't grab screnshot: appId:" << m_appId << " target:" << m_target;
    }
}

void SessionGrabber::removeScreenshot()
{
    const QString path = cachePath(m_appId);
    QFile::remove(path);
}

void SessionGrabber::grabReady()
{
    QFuture<QString> f = QtConcurrent::run(saveScreenshot, m_appId, m_grabResult);
    m_watcher = new QFutureWatcher<QString>(this);
    m_watcher->setFuture(f);
    connect(m_watcher, &QFutureWatcher<QString>::finished, this, &SessionGrabber::saveFinished);
}

void SessionGrabber::saveFinished()
{
    setPath(m_watcher->future().result());
    delete m_watcher;
    m_watcher = nullptr;
    m_grabResult.clear();
    Q_EMIT screenshotGrabbed();
}
