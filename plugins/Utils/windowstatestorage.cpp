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

#include "windowstatestorage.h"

#include <QtConcurrent>
#include <QDebug>
#include <QFutureSynchronizer>
#include <QSqlQuery>
#include <QSqlError>
#include <QSqlResult>
#include <QRect>

QMutex WindowStateStorage::s_mutex;

WindowStateStorage::WindowStateStorage(QObject *parent):
    QObject(parent)
{
    QString dbPath = QDir::homePath() + "/.cache/unity8/";
    m_db = QSqlDatabase::addDatabase(QStringLiteral("QSQLITE"));
    QDir dir;
    dir.mkpath(dbPath);
    m_db.setDatabaseName(dbPath + "windowstatestorage.sqlite");
    initdb();
}

WindowStateStorage::~WindowStateStorage()
{
    QFutureSynchronizer<void> futureSync;
    for (int i = 0; i < m_asyncQueries.count(); ++i) {
        futureSync.addFuture(m_asyncQueries[i]);
    }
    futureSync.waitForFinished();
    m_db.close();
}

void WindowStateStorage::saveGeometry(const QString &windowId, const QRect &rect)
{
    QMutexLocker mutexLocker(&s_mutex);

    QString queryString = QStringLiteral("INSERT OR REPLACE INTO geometry (windowId, x, y, width, height) values ('%1', '%2', '%3', '%4', '%5');")
            .arg(windowId)
            .arg(rect.x())
            .arg(rect.y())
            .arg(rect.width())
            .arg(rect.height());

    QFuture<void> future = QtConcurrent::run(executeAsyncQuery, queryString);
    m_asyncQueries.append(future);

    QFutureWatcher<void> *futureWatcher = new QFutureWatcher<void>();
    futureWatcher->setFuture(future);
    connect(futureWatcher, &QFutureWatcher<void>::finished,
            this,
            [=](){ m_asyncQueries.removeAll(futureWatcher->future());
                   futureWatcher->deleteLater(); });
}

void WindowStateStorage::executeAsyncQuery(const QString &queryString)
{
    QMutexLocker l(&s_mutex);
    QSqlQuery query;

    bool ok = query.exec(queryString);
    if (!ok) {
        qWarning() << "Error executing query" << queryString
                   << "Driver error:" << query.lastError().driverText()
                   << "Database error:" << query.lastError().databaseText();
    }
}

QRect WindowStateStorage::getGeometry(const QString &windowId, const QRect &defaultValue)
{
    QMutexLocker l(&s_mutex);
    QString queryString = QStringLiteral("SELECT * FROM geometry WHERE windowId = '%1';")
            .arg(windowId);
    QSqlQuery query;

    bool ok = query.exec(queryString);
    if (!ok) {
        qWarning() << "Error retrieving window state for" << windowId
                   << "Driver error:" << query.lastError().driverText()
                   << "Database error:" << query.lastError().databaseText();
        return defaultValue;
    }
    if (!query.first()) {
        return defaultValue;
    }
    return QRect(query.value(QStringLiteral("x")).toInt(), query.value(QStringLiteral("y")).toInt(), query.value(QStringLiteral("width")).toInt(), query.value(QStringLiteral("height")).toInt());
}

void WindowStateStorage::initdb()
{
    m_db.open();
    if (!m_db.open()) {
        qWarning() << "Error opening state database:" << m_db.lastError().driverText() << m_db.lastError().databaseText();
        return;
    }

    if (!m_db.tables().contains(QStringLiteral("geometry"))) {
        QSqlQuery query;
        query.exec(QStringLiteral("CREATE TABLE geometry(windowId TEXT UNIQUE, x INTEGER, y INTEGER, width INTEGER, height INTEGER);"));
    }
}
