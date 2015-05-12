/*
 * Copyright (C) 2015 Canonical, Ltd.
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

#ifndef UNITYUTIL_TIMER_H
#define UNITYUTIL_TIMER_H

#include "ElapsedTimer.h"

#include <QObject>
#include <QPointer>
#include <QTimer>

namespace UnityUtil {

/** Defines an interface for a Timer. Useful for tests. */
class AbstractTimer : public QObject
{
    Q_OBJECT
public:
    AbstractTimer(QObject *parent) : QObject(parent), m_isRunning(false) {}
    virtual int interval() const = 0;
    virtual void setInterval(int msecs) = 0;
    virtual void start() { m_isRunning = true; }
    virtual void stop() { m_isRunning = false; }
    bool isRunning() const { return m_isRunning; }
    virtual bool isSingleShot() const = 0;
    virtual void setSingleShot(bool value) = 0;
Q_SIGNALS:
    void timeout();
private:
    bool m_isRunning;
};

/** A QTimer wrapper */
class Timer : public AbstractTimer
{
    Q_OBJECT
public:
    Timer(QObject *parent = nullptr);

    int interval() const override;
    void setInterval(int msecs) override;
    void start() override;
    void stop() override;
    bool isSingleShot() const override;
    void setSingleShot(bool value) override;
private:
    QTimer m_timer;
};

class AbstractTimerFactory
{
public:
    virtual ~AbstractTimerFactory() {}
    virtual AbstractTimer *create(QObject *parent = nullptr) = 0;
};

class TimerFactory : public AbstractTimerFactory
{
public:
    AbstractTimer *create(QObject *parent = nullptr) override { return new Timer(parent); }
};

} // namespace UnityUtil

#endif // UNITYUTIL_TIMER_H
