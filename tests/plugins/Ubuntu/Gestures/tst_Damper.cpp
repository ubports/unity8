/*
 * Copyright (C) 2013 Canonical, Ltd.
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

#include <QtTest/QtTest>

#include <Damper.h>

class tst_Damper : public QObject
{
    Q_OBJECT
private Q_SLOTS:
    void negativeMovement();
};

void tst_Damper::negativeMovement()
{
    Damper<qreal> damper;

    damper.setMaxDelta(3.0);
    damper.reset(0.0);
    damper.update(-5.0);
    QCOMPARE(damper.value(), -2.0);
}

QTEST_MAIN(tst_Damper)

#include "tst_Damper.moc"
