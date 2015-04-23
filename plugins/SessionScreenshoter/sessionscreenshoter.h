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

#ifndef SESSIONSCREENSHOTER_H
#define SESSIONSCREENSHOTER_H

#include <QObject>
#include <QSharedPointer>
#include <QFutureWatcher>

class QQuickItem;
class QQuickItemGrabResult;

/**
 * SessionScreenshoter saves to disk screenshots of the given item.
 * Images are saved into $HOME/.cache/app_shots/appId.png
 * It also handles giving back the screenshot path if it already exists (e.g. because a reboot)
 */
class SessionScreenshoter : public QObject
{
    Q_OBJECT

    /// appId is the key of the screenshot name.
    Q_PROPERTY(QString appId READ appId WRITE setAppdId NOTIFY appdIdChanged)

    /// path where the screenshot is saved, can be empty if no screenshot has been taken yet.
    Q_PROPERTY(QString path READ path NOTIFY pathChanged)

    /// target item for the screenshot taking.
    Q_PROPERTY(QQuickItem *target READ target WRITE setTarget NOTIFY targetChanged)

public:
    explicit SessionScreenshoter(QObject *parent = 0);

    QString appId() const;
    void setAppdId(const QString &appId);

    QQuickItem *target() const;
    void setTarget(QQuickItem *target);

    QString path() const;

    /// Starts taking a screenshot. Emits screenshotTaken when ready.
    Q_INVOKABLE void take();

    /// Removes the existing screenshot
    Q_INVOKABLE void removeScreenshot();

Q_SIGNALS:
    void appdIdChanged();
    void targetChanged();
    void pathChanged();

    /// Signals screenshot taking has finished.
    void screenshotTaken();

private Q_SLOTS:
    void grabReady();
    void saveFinished();

private:
    void setPath(const QString &path);

    QString m_appId;
    QString m_path;
    QQuickItem *m_target;
    QSharedPointer<QQuickItemGrabResult> m_grabResult;
    QSharedPointer<QFutureWatcher<QString>> m_watcher;
};

#endif
