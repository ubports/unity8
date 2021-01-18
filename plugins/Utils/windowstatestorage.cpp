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

#include "windowstatestorage.h"

#include <QDebug>
#include <QDir>
#include <QMetaObject>
#include <QObject>
#include <QSqlQuery>
#include <QSqlError>
#include <QSqlResult>
#include <QStandardPaths>
#include <QRect>
#include <unity/shell/application/ApplicationInfoInterface.h>


class AsyncQuery: public QObject
{
    Q_OBJECT

public:
    AsyncQuery(const QString& dbName):
        m_dbName(dbName)
    {
    }

    ~AsyncQuery()
    {
        QSqlDatabase::removeDatabase(m_connectionName);
    }

    Q_PROPERTY (const QString dbName READ getDbName)

    Q_INVOKABLE const QString getDbName()
    {
        if (!m_ok) {
            return "ERROR";
        }
        QSqlDatabase connection = QSqlDatabase::database(m_connectionName);
        return connection.databaseName();
    }

    Q_INVOKABLE bool initdb()
    {
        if (m_ok) {
            return true;
        }
        QSqlDatabase connection = QSqlDatabase::addDatabase(QStringLiteral("QSQLITE"), m_connectionName);
        connection.setDatabaseName(m_dbName);
        connection.setConnectOptions(QStringLiteral("QSQLITE_BUSY_TIMEOUT=1000"));
        if (!connection.open()) {
            qWarning() << "AsyncQuery::initdb: Error opening state database. Window positions will not be saved or restored." << m_dbName << connection.lastError().driverText() << connection.lastError().databaseText();
            return false;
        }
        QSqlQuery query(connection);

        if (!connection.tables().contains(QStringLiteral("geometry"))) {
            QString geometryQuery = QStringLiteral("CREATE TABLE geometry(windowId TEXT UNIQUE, x INTEGER, y INTEGER, width INTEGER, height INTEGER);");
            if (!query.exec(geometryQuery)) {
                logSqlError(query);
                return false;
            }
        }

        if (!connection.tables().contains(QStringLiteral("state"))) {
            QString stateQuery = QStringLiteral("CREATE TABLE state(windowId TEXT UNIQUE, state INTEGER);");
            if (!query.exec(stateQuery)) {
                logSqlError(query);
                return false;
            }
        }

        if (!connection.tables().contains(QStringLiteral("stage"))) {
            QString stageQuery = QStringLiteral("CREATE TABLE stage(appId TEXT UNIQUE, stage INTEGER);");
            if (!query.exec(stageQuery)) {
                logSqlError(query);
                return false;
            }
        }
        m_ok = true;
        return true;
    }

    Q_INVOKABLE int getState(const QString &windowId) const
    {
        if (!m_ok) {
            return -1;
        }
        QSqlDatabase connection = QSqlDatabase::database(m_connectionName);
        QSqlQuery query(connection);
        query.prepare(m_getStateQuery);
        query.bindValue(":windowId", windowId);
        query.exec();
        if (!query.isActive() || !query.isSelect()) {
            logSqlError(query);
            return -1;
        }
        if (!query.first()) {
            return -1;
        }
        bool converted = false;
        QVariant resultStr = query.value(0);
        int result = resultStr.toInt(&converted);
        if (converted) {
            return result;
        } else {
            qWarning() << "getState result expected integer, got " << resultStr;
            return -1;
        }
    }

    Q_INVOKABLE QRect getGeometry(const QString &windowId) const
    {
        if (!m_ok) {
            return QRect();
        }
        QSqlDatabase connection = QSqlDatabase::database(m_connectionName);
        QSqlQuery query(connection);
        query.prepare(m_getGeometryQuery);
        query.bindValue(":windowId", windowId);
        query.exec();
        if (!query.isActive() || !query.isSelect()) {
            logSqlError(query);
            return QRect();
        }

        if (!query.first()) {
            return QRect();
        }

        bool xConverted, yConverted, widthConverted, heightConverted = false;
        int x, y, width, height;
        QVariant xResultStr = query.value(QStringLiteral("x"));
        QVariant yResultStr = query.value(QStringLiteral("y"));
        QVariant widthResultStr = query.value(QStringLiteral("width"));
        QVariant heightResultStr = query.value(QStringLiteral("height"));
        x = xResultStr.toInt(&xConverted);
        y = yResultStr.toInt(&yConverted);
        width = widthResultStr.toInt(&widthConverted);
        height = heightResultStr.toInt(&heightConverted);

        if (xConverted  && yConverted && widthConverted && heightConverted) {
            return QRect(x, y, width, height);
        } else {
            qWarning() << "getGeometry result expected integers, got x:"
                    << xResultStr << "y:" << yResultStr << "width" << widthResultStr
                    << "height:" << heightResultStr;
            return QRect();
        }

    }

    Q_INVOKABLE int getStage(const QString &appId) const
    {
        if (!m_ok) {
            return -1;
        }
        QSqlDatabase connection = QSqlDatabase::database(m_connectionName);
        QSqlQuery query(connection);
        query.prepare(m_getStageQuery);
        query.bindValue(":appId", appId);
        query.exec();
        if (!query.isActive() || !query.isSelect()) {
            logSqlError(query);
            return -1;
        }
        if (!query.first()) {
            return -1;
        }
        bool converted = false;
        QVariant resultStr = query.value(0);
        int result = resultStr.toInt(&converted);
        if (converted) {
            return result;
        } else {
            qWarning() << "getStage result expected integer, got " << resultStr;
            return -1;
        }
    }

public Q_SLOTS:

    void saveState(const QString &windowId, WindowStateStorage::WindowState state)
    {
        if (!m_ok) {
            return;
        }
        QSqlDatabase connection = QSqlDatabase::database(m_connectionName);
        QSqlQuery query(connection);
        query.prepare(m_saveStateQuery);
        query.bindValue(":windowId", windowId);
        query.bindValue(":state", (int)state);
        if (!query.exec()) {
            logSqlError(query);
        }
    }

    void saveGeometry(const QString &windowId, const QRect &rect)
    {
        if (!m_ok) {
            return;
        }
        QSqlDatabase connection = QSqlDatabase::database(m_connectionName);
        QSqlQuery query(connection);
        query.prepare(m_saveGeometryQuery);
        query.bindValue(":windowId", windowId);
        query.bindValue(":x", rect.x());
        query.bindValue(":y", rect.y());
        query.bindValue(":width", rect.width());
        query.bindValue(":height", rect.height());
        if (!query.exec()) {
            logSqlError(query);
        }
    }

    void saveStage(const QString &appId, int stage)
    {
        if (!m_ok) {
            return;
        }
        QSqlDatabase connection = QSqlDatabase::database(m_connectionName);
        QSqlQuery query(connection);
        query.prepare(m_saveStageQuery);
        query.bindValue(":appId", appId);
        query.bindValue(":stage", stage);
        if (!query.exec()) {
            logSqlError(query);
        }
    }

private:
    const QString m_connectionName = QStringLiteral("WindowStateStorage");
    const QString m_getStateQuery = QStringLiteral("SELECT state FROM state WHERE windowId = :windowId");
    const QString m_saveStateQuery = QStringLiteral("INSERT OR REPLACE INTO state (windowId, state) values (:windowId, :state)");
    const QString m_getGeometryQuery = QStringLiteral("SELECT * FROM geometry WHERE windowId = :windowId");
    const QString m_saveGeometryQuery = QStringLiteral("INSERT OR REPLACE INTO geometry (windowId, x, y, width, height) values (:windowId, :x, :y, :width, :height)");
    const QString m_getStageQuery = QStringLiteral("SELECT stage FROM stage WHERE appId = :appId");
    const QString m_saveStageQuery = QStringLiteral("INSERT OR REPLACE INTO stage (appId, stage) values (:appId, :stage)");
    QString m_dbName;
    bool m_ok = false;

    void logSqlError(const QSqlQuery query) const
    {
        qWarning() << "Error executing query" << query.lastQuery()
                << "Driver error:" << query.lastError().driverText()
                << "Database error:" << query.lastError().databaseText();
    }
};

WindowStateStorage::WindowStateStorage(const QString& dbName, QObject *parent):
    QObject(parent),
    m_thread()
{
    qRegisterMetaType<WindowStateStorage::WindowState>("WindowStateStorage::WindowState");
    QString dbFile;
    if (dbName == nullptr) {
        const QString dbPath = QStandardPaths::writableLocation(QStandardPaths::GenericCacheLocation) + QStringLiteral("/unity8/");
        QDir dir;
        dir.mkpath(dbPath);
        dbFile = QString(dbPath) + QStringLiteral("windowstatestorage.sqlite");
    } else {
        dbFile = dbName;
    }
    m_asyncQuery = new AsyncQuery(dbFile);
    m_asyncQuery->moveToThread(&m_thread);
    connect(&m_thread, &QThread::finished, m_asyncQuery, &QObject::deleteLater);
    m_thread.start();
    // Note that we're relying on initdb being called before any other methods
    // on AsyncQuery. Given the current behavior of QueuedConnection (slots
    // invoked in the order they are received), this is fine.
    QMetaObject::invokeMethod(m_asyncQuery, "initdb",
                              Qt::QueuedConnection);
    connect(this, &WindowStateStorage::saveState, m_asyncQuery, &AsyncQuery::saveState);
    connect(this, &WindowStateStorage::saveGeometry, m_asyncQuery, &AsyncQuery::saveGeometry);
    connect(this, &WindowStateStorage::saveStage, m_asyncQuery, &AsyncQuery::saveStage);
}

WindowStateStorage::~WindowStateStorage()
{
    m_thread.quit();
    m_thread.wait();
}

WindowStateStorage::WindowState WindowStateStorage::getState(const QString &windowId, WindowStateStorage::WindowState defaultValue) const
{
    int state;

    QMetaObject::invokeMethod(m_asyncQuery, "getState", Qt::BlockingQueuedConnection,
                            Q_RETURN_ARG(int, state),
                            Q_ARG(const QString&, windowId)
                            );

    if (state == -1) {
        return defaultValue;
    }

    return (WindowState)state;
}

int WindowStateStorage::getStage(const QString &appId, int defaultValue) const
{
    int stage;

    QMetaObject::invokeMethod(m_asyncQuery, "getStage", Qt::BlockingQueuedConnection,
                            Q_RETURN_ARG(int, stage),
                            Q_ARG(const QString&, appId)
                            );

    if (stage == -1) {
        return defaultValue;
    }

    return stage;
}

QRect WindowStateStorage::getGeometry(const QString &windowId, const QRect &defaultValue) const
{
    QRect geometry;
    QMetaObject::invokeMethod(m_asyncQuery, "getGeometry", Qt::BlockingQueuedConnection,
                            Q_RETURN_ARG(QRect, geometry),
                            Q_ARG(const QString&, windowId)
                            );
    if (geometry.isNull() || !geometry.isValid()) {
        return defaultValue;
    }
    return geometry;
}

const QString WindowStateStorage::getDbName()
{
    QString dbName;
    QMetaObject::invokeMethod(m_asyncQuery, "getDbName", Qt::BlockingQueuedConnection,
                              Q_RETURN_ARG(QString, dbName)
                              );
    return QString(dbName);
}

Mir::State WindowStateStorage::toMirState(WindowState state) const
{
    // assumes a single state (not an OR of several)
    switch (state) {
        case WindowStateMaximized:             return Mir::MaximizedState;
        case WindowStateMinimized:             return Mir::MinimizedState;
        case WindowStateFullscreen:            return Mir::FullscreenState;
        case WindowStateMaximizedLeft:         return Mir::MaximizedLeftState;
        case WindowStateMaximizedRight:        return Mir::MaximizedRightState;
        case WindowStateMaximizedHorizontally: return Mir::HorizMaximizedState;
        case WindowStateMaximizedVertically:   return Mir::VertMaximizedState;
        case WindowStateMaximizedTopLeft:      return Mir::MaximizedTopLeftState;
        case WindowStateMaximizedTopRight:     return Mir::MaximizedTopRightState;
        case WindowStateMaximizedBottomLeft:   return Mir::MaximizedBottomLeftState;
        case WindowStateMaximizedBottomRight:  return Mir::MaximizedBottomRightState;

        case WindowStateNormal:
        case WindowStateRestored:
        default:
            return Mir::RestoredState;
    }
}

#include "windowstatestorage.moc"
