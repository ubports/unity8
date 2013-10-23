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
 * Author: Lars Uebernickel <lars.uebernickel@canonical.com>
 */

#include "timeformatter.h"

#include <QtTest>
#include <QDebug>

class TimeFormatterTest : public QObject
{
    Q_OBJECT
private Q_SLOTS:

    void initTestCase()
    {
        setenv("UNITY_TEST_ENV", "1", 1);
    }

    void cleanupTestCase()
    {
        unsetenv("UNITY_TEST_ENV");
    }

    void testFormat()
    {
        const QString format = "hh:mm dd.MM.yy";

        QDateTime time = QDateTime::currentDateTime();

        TimeFormatter formatter;
        formatter.setTime(time.toMSecsSinceEpoch() * 1000);
        formatter.setFormat(format);

        QCOMPARE(formatter.timeString(), time.toString(format));
    }

    void testFormatStrF()
    {
        const QString format = "%d-%m-%Y %I:%M%p";

        QDateTime time = QDateTime::currentDateTime();

        StrFTimeFormatter formatter;
        formatter.setTime(time.toMSecsSinceEpoch() / 1000); // strftime in seconds since epoc
        formatter.setFormat(format);

        QCOMPARE(formatter.timeString(), time.toString("dd-MM-yyyy hh:mmAP"));
    }
};

QTEST_GUILESS_MAIN(TimeFormatterTest)

#include "timeformattertest.moc"
