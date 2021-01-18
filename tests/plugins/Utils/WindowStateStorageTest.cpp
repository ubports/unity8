/*
 * Copyright (C) 2017 Canonical, Ltd.
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
 */

#include "windowstatestorage.h"

#include <QTest>
#include <QStandardPaths>

class WindowStateStorageTest : public QObject
{
    Q_OBJECT

private Q_SLOTS:
    void initTestCase() {
        QStandardPaths::setTestModeEnabled(true);
    }

    void init()
    {
        storage = new WindowStateStorage(":memory:", this);
    }

    void cleanup()
    {
        delete storage;
    }

    void testDbNameMemory() {
        QCOMPARE(storage->getDbName(), QStringLiteral(":memory:"));
    }

    // This test serves as a reminder: if you're changing the databse location,
    // copy the old database or risk the wrath of long-time users.
    void testDbNameDefault() {
        delete storage;
        storage = new WindowStateStorage(nullptr, this);
        QCOMPARE(storage->getDbName(), QStandardPaths::writableLocation(QStandardPaths::GenericCacheLocation) + QStringLiteral("/unity8/windowstatestorage.sqlite"));
    }

    // Ensure that the WindowStateStorage object can be used even if opening
    // the database fails, just returning default values.
    void testErrorBehavior() {
        QString id{QTest::currentTestFunction()};
        QRect defaultValue{1, 1, 1, 1};
        WindowStateStorage::WindowState state{WindowStateStorage::WindowState::WindowStateMaximizedTopLeft};
        WindowStateStorage::WindowState defaultState{WindowStateStorage::WindowState::WindowStateMaximizedBottomRight};

        delete storage;
        QTest::ignoreMessage(QtWarningMsg, "AsyncQuery::initdb: Error opening state database  \"/nonexistent/there/is/no/way/this/exists/\" \"Error opening database\" \"unable to open database file\"");
        QTest::ignoreMessage(QtWarningMsg, "WindowStateStorage Failed to initialize AsyncQuery! Windows will not be restored to their previous location.");
        storage = new WindowStateStorage(QStringLiteral("/nonexistent/there/is/no/way/this/exists/"), this);
        QCOMPARE(storage->getDbName(), QStringLiteral("ERROR"));

        storage->saveState(id, state);
        storage->saveGeometry(id, QRect(2, 2, 2, 2));
        storage->saveStage(id, 2);
        QCOMPARE(storage->getState(id, defaultState), defaultState);
        QCOMPARE(storage->getGeometry(id, defaultValue), defaultValue);
        QCOMPARE(storage->getStage(id, 4), 4);
    }

    void testSaveRestoreState() {
        const WindowStateStorage::WindowState state{WindowStateStorage::WindowState::WindowStateMaximizedTopLeft};
        storage->saveState(QTest::currentTestFunction(), state);
        QTRY_COMPARE(storage->getState(QTest::currentTestFunction(), WindowStateStorage::WindowState::WindowStateNormal), state);
    }

    void testSaveRestoreGeometry() {
        const QRect geometry{10, 20, 30, 40};
        storage->saveGeometry(QTest::currentTestFunction(), geometry);
        QTRY_COMPARE(storage->getGeometry(QTest::currentTestFunction(), QRect()), geometry);
    }

    void testSaveRestoreStage() {
        const int stage{1};
        storage->saveStage(QTest::currentTestFunction(), stage);
        QTRY_COMPARE(storage->getStage(QTest::currentTestFunction(), 0), stage);
    }

    void testProtectAgainstInvalidGeometry() {
        const QRect geometry{10, 20, 0, 10}; // zero-width (invalid) rectangle
        storage->saveGeometry(QTest::currentTestFunction(), geometry);
        const QRect defaultGeometry{10, 20, 30, 40};
        const QRect loadedGeometry = storage->getGeometry(QTest::currentTestFunction(), defaultGeometry);
        // ensure we don't load a broken geometry, instead we fall back to the default one
        QCOMPARE(loadedGeometry, defaultGeometry);
    }

    void testProtectAgainstSqlInjection() {
        QString naughtyAppId = QStringLiteral("stageQuery;DROP TABLE stage");
        QString naughtyAppIdSingleQuotes = QStringLiteral("stageQuery';DROP TABLE stage");
        QString naughtyAppIdDoubleQuotes = QStringLiteral("stageQuery\";DROP TABLE stage");
        QString naughtyAppIdBackslashes = QStringLiteral("stageQuery\\\";DROP TABLE stage");
        storage->saveStage(naughtyAppId, 1);
        QTRY_COMPARE(storage->getStage(naughtyAppId, 0), 1);
        storage->saveStage(naughtyAppIdSingleQuotes, 2);
        QTRY_COMPARE(storage->getStage(naughtyAppIdSingleQuotes, 0), 2);
        storage->saveStage(naughtyAppIdDoubleQuotes, 3);
        QTRY_COMPARE(storage->getStage(naughtyAppIdDoubleQuotes, 0), 3);
        storage->saveStage(naughtyAppIdBackslashes, 4);
        QTRY_COMPARE(storage->getStage(naughtyAppIdBackslashes, 0), 4);
    }

private:
    WindowStateStorage * storage{nullptr};
};

QTEST_GUILESS_MAIN(WindowStateStorageTest)
#include "WindowStateStorageTest.moc"
