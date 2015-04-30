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

#ifndef SESSIONGRABBER_H
#define SESSIONGRABBER_H

#include <QObject>
#include <QSharedPointer>
#include <QFutureWatcher>

class QQuickItem;
class QQuickItemGrabResult;

/**
 * SessionGrabber saves to disk screenshots of the given item.
 * Images are saved into $HOME/.cache/app_shots/appId.png
 * It also handles giving back the screenshot path if it already exists (e.g. because a reboot)
 */
class SessionGrabber : public QObject
{
    Q_OBJECT

    /// appId is the key of the screenshot name.
    Q_PROPERTY(QString appId READ appId WRITE setAppId NOTIFY appIdChanged)

    /// path where the screenshot is saved, can be empty if no screenshot has been grabbed yet.
    Q_PROPERTY(QString path READ path NOTIFY pathChanged)

    /// target item for the screenshot grabbing.
    Q_PROPERTY(QQuickItem *target READ target WRITE setTarget NOTIFY targetChanged)

public:
    explicit SessionGrabber(QObject *parent = 0);

    QString appId() const;
    void setAppId(const QString &appId);

    QQuickItem *target() const;
    void setTarget(QQuickItem *target);

    QString path() const;

    /// Starts grabbing a screenshot. Emits screenshotGrabbed when ready.
    Q_INVOKABLE void grab();

    /// Removes the existing screenshot
    Q_INVOKABLE void removeScreenshot();

Q_SIGNALS:
    void appIdChanged();
    void targetChanged();
    void pathChanged();

    /// Signals screenshot grabbing has finished.
    void screenshotGrabbed();

private Q_SLOTS:
    void grabReady();
    void saveFinished();

private:
    void setPath(const QString &path);

    QString m_appId;
    QString m_path;
    QQuickItem *m_target;
    QFutureWatcher<QString> *m_watcher;
    QSharedPointer<QQuickItemGrabResult> m_grabResult;
};

#endif
