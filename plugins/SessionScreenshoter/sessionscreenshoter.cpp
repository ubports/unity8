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

#include "sessionscreenshoter.h"

#include <QDebug>
#include <QQuickItem>
#include <QQuickItemGrabResult>
#include <QtConcurrent>

static QString cachePath()
{
    return QDir::homePath() + "/.cache/app_shots/";
}

SessionScreenshoter::SessionScreenshoter(QObject *parent)
    : QObject(parent),
      m_target(nullptr)
{
}

QString SessionScreenshoter::appId() const
{
    return m_appId;
}

void SessionScreenshoter::setAppdId(const QString &appId)
{
    if (appId != m_appId) {
        m_appId = appId;
        const QString path = cachePath() + appId + ".png";
        if (QFile::exists(path)) {
            setPath(path);
        }
    }
}

QQuickItem *SessionScreenshoter::target() const
{
    return m_target;
}

void SessionScreenshoter::setTarget(QQuickItem *target)
{
    if (target != m_target) {
        m_target = target;
        Q_EMIT targetChanged();
    }
}

QString SessionScreenshoter::path() const
{
    return m_path;
}

void SessionScreenshoter::setPath(const QString &path)
{
    if (path != m_path) {
        m_path = path;
        Q_EMIT pathChanged();
    }
}

static QString saveScreenshot(const QString &appId, const QSharedPointer<QQuickItemGrabResult> grabResult)
{
    const QImage image = grabResult->image();
    const QString cPath = cachePath();
    QDir d;
    d.mkpath(cPath);
    const QString path = cPath + appId + ".png";
    bool b = image.save(path);
    if (b) {
        return path;
    } else {
        return QString();
    }
}

void SessionScreenshoter::take()
{
    if (!m_grabResult.isNull()) {
        qWarning() << "Asked to take a screenshot when there's one already being taken, ignoring";
        return;
    }

    if (m_target && !m_appId.isEmpty()) {
        // grabToImage runs in a separate thread
        m_grabResult = m_target->grabToImage();
        connect(m_grabResult.data(), &QQuickItemGrabResult::ready, this, &SessionScreenshoter::grabReady);
    } else {
        qWarning() << "Can't take screnshot: appId:" << m_appId << " target:" << m_target;
    }
}

void SessionScreenshoter::removeScreenshot()
{
    const QString path = cachePath() + m_appId + ".png";
    QFile::remove(path);
}

void SessionScreenshoter::grabReady()
{
    QFuture<QString> f = QtConcurrent::run(saveScreenshot, m_appId, m_grabResult);
    m_watcher.reset(new QFutureWatcher<QString>(this));
    m_watcher->setFuture(f);
    connect(m_watcher.data(), &QFutureWatcher<QString>::finished, this, &SessionScreenshoter::saveFinished);
}

void SessionScreenshoter::saveFinished()
{
    setPath(m_watcher->future().result());
    m_watcher.clear();
    m_grabResult.clear();
    Q_EMIT screenshotTaken();
}
