/*
 * Copyright (C) 2016 Canonical, Ltd.
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

#ifndef MOCK_OPERATION_H
#define MOCK_OPERATION_H

#include <QObject>

class MockOperation : public QObject
{
    Q_OBJECT
    Q_PROPERTY(bool running READ running NOTIFY runningChanged) // only in mock

public:
    explicit MockOperation(QObject *parent = 0);

    Q_INVOKABLE void start(QObject *observer);
    Q_INVOKABLE void cancel();

    Q_INVOKABLE void mockSuccess(unsigned int uid); // only in mock
    Q_INVOKABLE void mockFailure(const QString &reason); // only in mock

    bool running() const; // only in mock

Q_SIGNALS:
    void runningChanged();

private:
    QObject *m_observer;
    bool m_running;
};

Q_DECLARE_METATYPE(MockOperation*)

#endif // MOCK_OPERATION_H
