/*
 * Copyright 2013 Canonical Ltd.
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation; version 3.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 * Authors:
 *      Michael Terry <michael.terry@canonical.com>
 */

#include "launcherbackend.h"

#include <QtTest>

class LauncherBackendTest : public QObject
{
    Q_OBJECT

private Q_SLOTS:
    void testFileNames()
    {
        LauncherBackend backend(false);

        backend.setStoredApplications(QStringList() << "rel-icon" << "abs-icon" << "invalid");
        QCOMPARE(backend.storedApplications(), QStringList() << "rel-icon" << "abs-icon");
    }

    void testPinning()
    {
        LauncherBackend backend(false);

        backend.setStoredApplications(QStringList() << "rel-icon" << "abs-icon");
        QCOMPARE(backend.isPinned("rel-icon"), false);
        QCOMPARE(backend.isPinned("abs-icon"), false);

        backend.setPinned("rel-icon", true);
        QCOMPARE(backend.isPinned("rel-icon"), true);

        backend.setStoredApplications(QStringList() << "rel-icon" << "abs-icon" << "no-name");
        QCOMPARE(backend.isPinned("rel-icon"), true);
        QCOMPARE(backend.isPinned("no-name"), false);

        backend.setPinned("no-name", true);
        backend.setStoredApplications(QStringList() << "rel-icon" << "abs-icon");
        QCOMPARE(backend.isPinned("rel-icon"), true);
        QCOMPARE(backend.isPinned("no-name"), false); // doesn't exist anymore!
    }

    void testIcon_data() {
        QTest::addColumn<QString>("appId");
        QTest::addColumn<QString>("expectedIcon");

        // Needs to expand a relative icon to the absolute path
        QTest::newRow("relative icon path") << "rel-icon" << QDir::currentPath() + "/rel-icon.svg";

        // In case an icon is not found on disk, it needs to fallback on image://theme/ for it
        QTest::newRow("fallback on theme") << "abs-icon" << "image://theme//path/to/icon.png";

        // Click packages have a relative icon path but an absolute path as a separate entry
        // As we don't want to rely on a click app being installed for the test, accept it with the image://theme fallback
        QTest::newRow("click package icon") << "click-icon" << "image://theme//path/to/some/click/app/click-icon.svg";
    }

    void testIcon() {
        QFETCH(QString, appId);
        QFETCH(QString, expectedIcon);

        LauncherBackend backend(false);
        backend.setStoredApplications(QStringList() << appId);

        QCOMPARE(backend.icon(appId), expectedIcon);
    }
};

QTEST_GUILESS_MAIN(LauncherBackendTest)
#include "launcherbackendtest.moc"
