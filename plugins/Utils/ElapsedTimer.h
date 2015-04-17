/*
 * Copyright (C) 2015 Canonical Ltd.
 *
 * This program is free software: you can redistribute it and/or modify it
 * under the terms of the GNU Lesser General Public License, as
 * published by the  Free Software Foundation; either version 2.1 or 3.0
 * of the License.
 *
 * This program is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY; without even the implied warranties of
 * MERCHANTABILITY, SATISFACTORY QUALITY or FITNESS FOR A PARTICULAR
 * PURPOSE.  See the applicable version of the GNU Lesser General Public
 * License for more details.
 *
 * You should have received a copy of both the GNU Lesser General Public
 * License along with this program. If not, see <http://www.gnu.org/licenses/>
 */

#ifndef UNITYUTIL_ELAPSEDTIMER_H
#define UNITYUTIL_ELAPSEDTIMER_H

#include <QElapsedTimer>

namespace UnityUtil {

class AbstractElapsedTimer {
public:
    virtual ~AbstractElapsedTimer() {}
    virtual void start() = 0;
    virtual qint64 msecsSinceReference() const = 0;
    virtual qint64 elapsed() const = 0;
};

/*
    A QElapsedTimer wrapper
 */
class ElapsedTimer : public AbstractElapsedTimer {
public:
    void start() override { m_timer.start(); }
    qint64 msecsSinceReference() const override { return m_timer.msecsSinceReference(); }
    qint64 elapsed() const override { return m_timer.elapsed(); }
private:
    QElapsedTimer m_timer;
};

/*
    A fake ElapsedTimer, useful for tests
 */
class FakeElapsedTimer : public AbstractElapsedTimer {
public:
    static qint64 msecsSinceEpoch;

    FakeElapsedTimer() { start(); }

    void start() override { m_msecsSinceReference = msecsSinceEpoch; }
    qint64 msecsSinceReference() const override { return m_msecsSinceReference; }
    qint64 elapsed() const override { return msecsSinceEpoch - m_msecsSinceReference; }

private:
    qint64 m_msecsSinceReference;
};

} // namespace UnityUtil

#endif // UNITYUTIL_ELAPSEDTIMER_H
