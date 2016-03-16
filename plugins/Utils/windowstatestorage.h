/*
 * Copyright 2015 Canonical Ltd.
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
#include <QMutex>
#include <QFuture>

class WindowStateStorage: public QObject
{
    Q_OBJECT
    Q_ENUMS(WindowState)
public:
    enum WindowState {
        WindowStateNormal,
        WindowStateMaximized
    };

    WindowStateStorage(QObject *parent = 0);
    virtual ~WindowStateStorage();

    Q_INVOKABLE void saveState(const QString &windowId, WindowState state);
    Q_INVOKABLE WindowState getState(const QString &windowId, WindowState defaultValue) const;

    Q_INVOKABLE void saveGeometry(const QString &windowId, const QRect rect);
    Q_INVOKABLE QRect getGeometry(const QString &windowId, const QRect defaultValue) const;

    Q_INVOKABLE void saveStage(const QString &appId, int stage);
    Q_INVOKABLE int getStage(const QString &appId) const;

private:
    void initdb();

    void saveValue(const QString &queryString);
    QSqlQuery getValue(const QString &queryString) const;

    static void executeAsyncQuery(const QString &queryString);
    static QMutex s_mutex;

    // NB: This is accessed from threads. Make sure to mutex it.
    QSqlDatabase m_db;

    QList< QFuture<void> > m_asyncQueries;
};
