/*
 * Copyright 2015-2016 Canonical Ltd.
 * Copyright 2021 UBports Foundation
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation; version 3.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with this program. If not, see <http://www.gnu.org/licenses/>.
 */

#include <QObject>
#include <QSqlDatabase>
#include <QSqlQuery>
#include <QMutex>
#include <QFuture>
#include <QThread>

// unity-api
#include <unity/shell/application/Mir.h>

class AsyncQuery;

class WindowStateStorage: public QObject
{
    Q_OBJECT
public:
    enum WindowState {
        WindowStateNormal = 1 << 0,
        WindowStateMaximized = 1 << 1,
        WindowStateMinimized = 1 << 2,
        WindowStateFullscreen = 1 << 3,
        WindowStateMaximizedLeft = 1 << 4,
        WindowStateMaximizedRight = 1 << 5,
        WindowStateMaximizedHorizontally = 1 << 6,
        WindowStateMaximizedVertically = 1 << 7,
        WindowStateMaximizedTopLeft = 1 << 8,
        WindowStateMaximizedTopRight = 1 << 9,
        WindowStateMaximizedBottomLeft = 1 << 10,
        WindowStateMaximizedBottomRight = 1 << 11,
        WindowStateRestored = 1 << 12
    };
    Q_ENUM(WindowState)
    Q_DECLARE_FLAGS(WindowStates, WindowState)
    Q_FLAG(WindowStates)

    WindowStateStorage(const QString& dbName = nullptr, QObject *parent = nullptr);
    virtual ~WindowStateStorage();

    Q_INVOKABLE WindowState getState(const QString &windowId, WindowState defaultValue) const;

    Q_INVOKABLE QRect getGeometry(const QString &windowId, const QRect &defaultValue) const;

    Q_INVOKABLE int getStage(const QString &appId, int defaultValue) const;

    Q_INVOKABLE Mir::State toMirState(WindowState state) const;

    Q_PROPERTY (const QString dbName READ getDbName)

    const QString getDbName();

Q_SIGNALS:
    void saveStage(const QString &appId, int stage);
    void saveGeometry(const QString &windowId, const QRect &rect);
    void saveState(const QString &windowId, WindowStateStorage::WindowState state);

private:
    QThread m_thread;
    AsyncQuery *m_asyncQuery;
};
