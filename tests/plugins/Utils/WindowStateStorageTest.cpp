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
        storage = new WindowStateStorage(this);
    }

    void cleanup()
    {
        delete storage;
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

private:
    WindowStateStorage * storage{nullptr};
};

QTEST_GUILESS_MAIN(WindowStateStorageTest)
#include "WindowStateStorageTest.moc"
