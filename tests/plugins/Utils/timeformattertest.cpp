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
#include "relativetimeformatter.h"

#include <locale.h>

#include <QtTest>
#include <QDebug>

class TimeFormatterTest : public QObject
{
    Q_OBJECT
private:
    void addTestData(QList<int> daysToAdd = QList<int>()) {
        QTest::addColumn<QDateTime>("time");

        Q_FOREACH(int dayToAdd, daysToAdd) {
            QDateTime time = QDateTime::currentDateTime().addDays(dayToAdd);
            QDateTime am(time); am.setTime(QTime(1, 1, 1));
            QDateTime midday(time); midday.setTime(QTime(12, 0, 0));
            QDateTime pm(time); pm.setTime(QTime(17, 59, 59));

            QTest::newRow(QString("%1day-am").arg(dayToAdd).toLatin1()) << am;
            QTest::newRow(QString("%1day-midday").arg(dayToAdd).toLatin1()) << midday;
            QTest::newRow(QString("%1day-pm").arg(dayToAdd).toLatin1()) << pm;
        }

    }

private Q_SLOTS:
    void initTestCase()
    {
        setenv("UNITY_TEST_ENV", "1", 1);
    }

    void cleanupTestCase()
    {
        unsetenv("UNITY_TEST_ENV");
    }

    void testTimeFormatter_Format_data() { addTestData(QList<int>() << 0); }
    void testTimeFormatter_Format()
    {
        QFETCH(QDateTime, time);
        const QString format = "hh:mm dd.MM.yy";

        TimeFormatter formatter;
        formatter.setTime(time.toMSecsSinceEpoch() * 1000);
        formatter.setFormat(format);

        QCOMPARE(formatter.timeString(), time.toString(format));
    }

    void tesGDatetTimeFormatter_Format_data() { addTestData(QList<int>() << 0); }
    void tesGDatetTimeFormatter_Format()
    {
        QFETCH(QDateTime, time);
        const QString format = "%d-%m-%Y %I:%M%p";

        GDateTimeFormatter formatter;
        formatter.setTime(time.toMSecsSinceEpoch() / 1000); // strftime in seconds since epoc
        formatter.setFormat(format);

        QCOMPARE(formatter.timeString(), time.toString("dd-MM-yyyy hh:mmAP"));
    }

    void tesRelativeTimeFormatter_FarBack_data() { addTestData(QList<int>() << -200 << -7); }
    void tesRelativeTimeFormatter_FarBack()
    {
        QFETCH(QDateTime, time);

        RelativeTimeFormatter formatter;
        formatter.setTime(time.toMSecsSinceEpoch() / 1000); // strftime in seconds since epoc

        QCOMPARE(formatter.timeString(), time.toString("ddd d MMM\u2003HH:mm"));
    }

    void tesRelativeTimeFormatter_WeekBack_data() { addTestData(QList<int>() << -6 << -2); }
    void tesRelativeTimeFormatter_WeekBack()
    {
        QFETCH(QDateTime, time);

        RelativeTimeFormatter formatter;
        formatter.setTime(time.toMSecsSinceEpoch() / 1000); // strftime in seconds since epoc

        QCOMPARE(formatter.timeString(), time.toString("ddd\u2003HH:mm"));
    }

    void tesRelativeTimeFormatter_Yesterday_data() { addTestData(QList<int>() << -1); }
    void tesRelativeTimeFormatter_Yesterday()
    {
        QFETCH(QDateTime, time);

        RelativeTimeFormatter formatter;
        formatter.setTime(time.toMSecsSinceEpoch() / 1000); // strftime in seconds since epoc

        QCOMPARE(formatter.timeString(), QString("Yesterday\u2003%1").arg(time.toString("HH:mm")));
    }

    void tesRelativeTimeFormatter_Today_data() { addTestData(QList<int>() << 0); }
    void tesRelativeTimeFormatter_Today()
    {
        QFETCH(QDateTime, time);

        RelativeTimeFormatter formatter;
        formatter.setTime(time.toMSecsSinceEpoch() / 1000); // strftime in seconds since epoc

        QCOMPARE(formatter.timeString(), time.toString("HH:mm"));
    }

    void tesRelativeTimeFormatter_Tomorrow_data() { addTestData(QList<int>() << 1); }
    void tesRelativeTimeFormatter_Tomorrow()
    {
        QFETCH(QDateTime, time);

        RelativeTimeFormatter formatter;
        formatter.setTime(time.toMSecsSinceEpoch() / 1000); // strftime in seconds since epoc

        QCOMPARE(formatter.timeString(), QString("Tomorrow\u2003%1").arg(time.toString("HH:mm")));
    }


    void tesRelativeTimeFormatter_WeekForward_data() { addTestData(QList<int>() << 2 << 6); }
    void tesRelativeTimeFormatter_WeekForward()
    {
        QFETCH(QDateTime, time);

        RelativeTimeFormatter formatter;
        formatter.setTime(time.toMSecsSinceEpoch() / 1000); // strftime in seconds since epoc

        QCOMPARE(formatter.timeString(), time.toString("ddd\u2003HH:mm"));
    }

    void tesRelativeTimeFormatter_FarForward_data() { addTestData(QList<int>() << 7 << 200); }
    void tesRelativeTimeFormatter_FarForward()
    {
        QFETCH(QDateTime, time);

        RelativeTimeFormatter formatter;
        formatter.setTime(time.toMSecsSinceEpoch() / 1000); // strftime in seconds since epoc

        QCOMPARE(formatter.timeString(), time.toString("ddd d MMM\u2003HH:mm"));
    }
};

QTEST_GUILESS_MAIN(TimeFormatterTest)

#include "timeformattertest.moc"
