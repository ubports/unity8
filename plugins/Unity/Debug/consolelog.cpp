/*
 * Copyright 2016 Canonical Ltd.
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation; version 3.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with this program. If not, see <http://www.gnu.org/licenses/>.
*/

#include "consolelog.h"

#include <unistd.h>
#include <stdio.h>
#include <thread>
#include <iostream>
#include <sys/ioctl.h>

#include <functional>

namespace
{

int wait_fd(std::function<int(void)> fn)
{
    int ret = -1;
    bool fd_blocked = false;
    do
    {
         ret = fn();
         fd_blocked = (errno == EINTR ||  errno == EBUSY);
         if (fd_blocked)
            QThread::msleep(10);
    }
    while (ret < 0);
    return ret;
}

#define PIPE_WAIT(val) wait_fd(std::bind(pipe, val))
#define DUP_WAIT(fd) wait_fd(std::bind(dup, fd))
#define DUP2_WAIT(fd1, fd2) wait_fd(std::bind(dup2, fd1, fd2))
#define CLOSE_WAIT(fd) wait_fd(std::bind(close, fd))

}

LogRedirector::LogRedirector()
    : m_ref(0)
    , m_stop(false)
{
    setObjectName("ConsoleLog");

    // make stdout & stderr streams unbuffered
    // so that we don't need to flush the streams
    // before capture and after capture
    // (fflush can cause a deadlock if the stream is currently being used)
    setvbuf(stdout,NULL,_IONBF,0);
    setvbuf(stderr,NULL,_IONBF,0);
}

void LogRedirector::run()
{
    PIPE_WAIT(m_pipe);

    int oldStdOut = DUP_WAIT(fileno(stdout));
    int oldStdErr = DUP_WAIT(fileno(stderr));

    DUP2_WAIT(m_pipe[WRITE], fileno(stdout));
    DUP2_WAIT(m_pipe[WRITE], fileno(stderr));
    CLOSE_WAIT(m_pipe[WRITE]);

    while(true) {
        {
            QMutexLocker lock(&m_mutex);
            if (m_stop) break;
        }
        checkLog();
        QThread::msleep(50);
    }

    DUP2_WAIT(oldStdOut, fileno(stdout));
    DUP2_WAIT(oldStdErr, fileno(stderr));

    CLOSE_WAIT(oldStdOut);
    CLOSE_WAIT(oldStdErr);
    CLOSE_WAIT(m_pipe[READ]);
}


void LogRedirector::checkLog()
{
    // Do not allow read to block with no data.
    // If we stop the thread while waiting a read,
    // it will block the main thread waiting for this thread to stop.
    int count = 0;
    ioctl(m_pipe[READ], FIONREAD, &count);
    if (count <= 0) return;

    std::string captured;
    std::string buf;
    const int bufSize = 1024;
    buf.resize(bufSize);
    int bytesRead = 0;
    bytesRead = read(m_pipe[READ], &(*buf.begin()), bufSize);
    while(bytesRead == bufSize)
    {
        captured += buf;
        bytesRead = 0;
        bytesRead = read(m_pipe[READ], &(*buf.begin()), bufSize);
    }
    if (bytesRead > 0)
    {
        buf.resize(bytesRead);
        captured += buf;
    }

    if (!captured.empty()) {
        Q_EMIT log(QString::fromStdString(captured));
    }
}

LogRedirector *LogRedirector::instance()
{
    static LogRedirector* log = nullptr;
    if (!log) {
        log = new LogRedirector();
    }
    return log;
}

void LogRedirector::add(ConsoleLog* logger)
{
    QMutexLocker lock(&m_mutex);
    connect(this, &LogRedirector::log, logger, &ConsoleLog::logged, Qt::UniqueConnection);

    m_ref++;
    if (!LogRedirector::instance()->isRunning()) {
        m_stop = false;
        LogRedirector::instance()->start();
    }
}

void LogRedirector::remove(ConsoleLog* logger)
{
    QMutexLocker lock(&m_mutex);
    disconnect(this, &LogRedirector::log, logger, &ConsoleLog::logged);

    m_ref = qMax(m_ref-1, 0);
    if (m_ref == 0 && LogRedirector::instance()->isRunning()) {
        m_stop = true;
        lock.unlock();
        LogRedirector::instance()->wait();
    }
}

ConsoleLog::ConsoleLog(QObject *parent)
    : QObject(parent)
    , m_enabled(false)
    , m_maxLines(60)
{
    auto updateEnabled = [this]() {
        if (m_enabled) {
            LogRedirector::instance()->add(this);
        } else {
            LogRedirector::instance()->remove(this);
        }
    };
    connect(this, &ConsoleLog::enabledChanged, this, updateEnabled);
}

ConsoleLog::~ConsoleLog()
{
    if (m_enabled) {
        LogRedirector::instance()->remove(this);
    }
}

void ConsoleLog::setEnabled(bool enabled)
{
    if (m_enabled == enabled) {
        return;
    }

    m_enabled = enabled;
    Q_EMIT enabledChanged();
}

QString ConsoleLog::out() const
{
    return m_out.join("\n");
}

void ConsoleLog::setMaxLines(int maxLines)
{
    if (m_maxLines == maxLines) {
        return;
    }

    m_maxLines = maxLines;
    while (m_out.count() > m_maxLines) {
        m_out.removeLast();
    }
    Q_EMIT outChanged();
    Q_EMIT maxLinesChanged();
}

void ConsoleLog::logged(QString captured)
{
    QStringList li = captured.split("\n", QString::SkipEmptyParts);
    li << m_out;
    m_out = li;
    while (m_out.count() > m_maxLines) {
        m_out.removeLast();
    }
    Q_EMIT outChanged();
}
