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
#include <QSqlQuery>
#include <QSqlError>
#include <QSqlResult>
#include <QRect>

QMutex WindowStateStorage::s_mutex;

WindowStateStorage::WindowStateStorage(QObject *parent):
    QObject(parent)
{
    m_db = QSqlDatabase::addDatabase("QSQLITE");
    m_db.setDatabaseName(QDir::homePath() + "/.cache/unity8/windowstatestorage.sqlite");
    initdb();
}

void WindowStateStorage::saveGeometry(const QString &windowId, const QRect &rect)
{
    QString queryString = QString("INSERT OR REPLACE INTO geometry (windowId, x, y, width, height) values ('%1', '%2', '%3', '%4', '%5');")
            .arg(windowId)
            .arg(rect.x())
            .arg(rect.y())
            .arg(rect.width())
            .arg(rect.height());

    QtConcurrent::run(executeAsyncQuery, queryString);
}

void WindowStateStorage::executeAsyncQuery(const QString &queryString)
{
    QMutexLocker l(&s_mutex);
    QSqlQuery query;

    bool ok = query.exec(queryString);
    if (!ok) {
        qWarning() << "Error esecuting query" << queryString
                   << "Driver error:" << query.lastError().driverText()
                   << "Database error:" << query.lastError().databaseText();
    }
}

QRect WindowStateStorage::getGeometry(const QString &windowId, const QRect &defaultValue)
{
    QMutexLocker l(&s_mutex);
    QString queryString = QString("SELECT * FROM geometry WHERE windowId = '%1';")
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
    return QRect(query.value("x").toInt(), query.value("y").toInt(), query.value("width").toInt(), query.value("height").toInt());
}

void WindowStateStorage::initdb()
{
    m_db.open();
    if (!m_db.open()) {
        qWarning() << "Error opening state database:" << m_db.lastError().driverText() << m_db.lastError().databaseText();
        return;
    }

    if (!m_db.tables().contains("windowproperties")) {
        QSqlQuery query;
        query.exec("CREATE TABLE IF NOT EXISTS geometry(windowId TEXT UNIQUE, x INTEGER, y INTEGER, width INTEGER, height INTEGER);");
    }
}
