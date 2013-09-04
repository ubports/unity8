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
#include <QDebug>

class LauncherBackendTest : public QObject
{
    Q_OBJECT

private Q_SLOTS:
    void testFileNames()
    {
        LauncherBackend backend(false);

        backend.setStoredApplications(QStringList() << "relative.path" << "/full/path");
        QCOMPARE(backend.storedApplications(), QStringList() << "relative.path" << "/full/path");
    }

    void testPinning()
    {
        LauncherBackend backend(false);

        backend.setStoredApplications(QStringList() << "one" << "two");
        QCOMPARE(backend.isPinned("one"), false);
        QCOMPARE(backend.isPinned("two"), false);

        backend.setPinned("two", true);
        QCOMPARE(backend.isPinned("two"), true);

        backend.setStoredApplications(QStringList() << "one" << "two" << "three");
        QCOMPARE(backend.isPinned("two"), true);
        QCOMPARE(backend.isPinned("three"), false);

        backend.setPinned("three", true);
        backend.setStoredApplications(QStringList() << "one" << "two");
        QCOMPARE(backend.isPinned("two"), true);
        QCOMPARE(backend.isPinned("three"), false); // doesn't exist anymore!
    }
};

QTEST_GUILESS_MAIN(LauncherBackendTest)
#include "launcherbackendtest.moc"
