/*
 * Copyright (C) 2014 Canonical, Ltd.
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
 *
 * Authored by: Nick Dedekind <nick.dedekind@canonical.com
 */

#ifndef MOCKCALLMANAGER_H
#define MOCKCALLMANAGER_H

#include <QObject>

class MockCallManager : public QObject
{
    Q_OBJECT
    Q_DISABLE_COPY(MockCallManager)

    Q_PROPERTY(QObject *foregroundCall READ foregroundCall WRITE setForegroundCall NOTIFY foregroundCallChanged)
    Q_PROPERTY(QObject *backgroundCall READ backgroundCall WRITE setBackgroundCall NOTIFY backgroundCallChanged)
    Q_PROPERTY(bool hasCalls READ hasCalls NOTIFY hasCallsChanged)
    Q_PROPERTY(bool callIndicatorVisible READ callIndicatorVisible WRITE setCallIndicatorVisible NOTIFY callIndicatorVisibleChanged)

public:
    explicit MockCallManager(QObject *parent = 0);

    static MockCallManager *instance();

    QObject* foregroundCall() const;
    QObject* backgroundCall() const;
    bool hasCalls() const;
    bool callIndicatorVisible() const;

    void setForegroundCall(QObject* foregroundCall);
    void setBackgroundCall(QObject* backgroundCall);
    void setCallIndicatorVisible(bool callIndicatorVisible);

Q_SIGNALS:
    void foregroundCallChanged();
    void backgroundCallChanged();
    void hasCallsChanged();
    void callIndicatorVisibleChanged();

private:
    QObject* m_foregroundCall;
    QObject* m_backgroundCall;
    bool m_callIndicatorVisible;
};

#endif // MOCKCALLMANAGER_H
