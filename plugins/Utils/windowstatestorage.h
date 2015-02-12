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

class WindowStateStorage: public QObject
{
    Q_OBJECT
public:
    WindowStateStorage(QObject *parent = 0);

    Q_INVOKABLE void saveGeometry(const QString &windowId, const QRect &rect);
    Q_INVOKABLE QRect getGeometry(const QString &windowId, const QRect &defaultValue);

private:
    void initdb();

    static void executeAsyncQuery(const QString &queryString);
    static QMutex s_mutex;

    // NB: This is accessed from threads. Make sure to mutex it.
    QSqlDatabase m_db;
};
