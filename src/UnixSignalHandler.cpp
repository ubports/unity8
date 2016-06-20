/*
 * Copyright (C) 2015 Canonical, Ltd.
 *
 * This program is free software: you can redistribute it and/or modify it
 * under the terms of the GNU General Public License version 3, as published
 * by the Free Software Foundation.
 *
 * This program is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY; without even the implied warranties of
 * MERCHANTABILITY, SATISFACTORY QUALITY, or FITNESS FOR A PARTICULAR
 * PURPOSE.  See the GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License along
 * with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 * Author: Marcus Tomlinson <marcus.tomlinson@canonical.com>
 */

#include "UnixSignalHandler.h"

#include <QDebug>

#include <csignal>
#include <sys/socket.h>
#include <unistd.h>

int UnixSignalHandler::sighupFd[2];
int UnixSignalHandler::sigintFd[2];
int UnixSignalHandler::sigtermFd[2];

UnixSignalHandler::UnixSignalHandler(const std::function<void()>& f, QObject *parent)
    : QObject(parent),
      m_func(f)
{
    if (::socketpair(AF_UNIX, SOCK_STREAM, 0, sighupFd))
    {
        qFatal("Couldn't create HUP socketpair");
    }
    if (::socketpair(AF_UNIX, SOCK_STREAM, 0, sigintFd))
    {
        qFatal("Couldn't create INT socketpair");
    }
    if (::socketpair(AF_UNIX, SOCK_STREAM, 0, sigtermFd))
    {
        qFatal("Couldn't create TERM socketpair");
    }

    m_socketNotifierHup = new QSocketNotifier(sighupFd[1], QSocketNotifier::Read, this);
    connect(m_socketNotifierHup, &QSocketNotifier::activated, this, &UnixSignalHandler::handleSigHup);
    m_socketNotifierInt = new QSocketNotifier(sigintFd[1], QSocketNotifier::Read, this);
    connect(m_socketNotifierInt, &QSocketNotifier::activated, this, &UnixSignalHandler::handleSigInt);
    m_socketNotifierTerm = new QSocketNotifier(sigtermFd[1], QSocketNotifier::Read, this);
    connect(m_socketNotifierTerm, &QSocketNotifier::activated, this, &UnixSignalHandler::handleSigTerm);
}

void UnixSignalHandler::hupSignalHandler(int)
{
    char a = 1;
    ::write(sighupFd[0], &a, sizeof(a));
}

void UnixSignalHandler::intSignalHandler(int)
{
    char a = 1;
    ::write(sigintFd[0], &a, sizeof(a));
}

void UnixSignalHandler::termSignalHandler(int)
{
    char a = 1;
    ::write(sigtermFd[0], &a, sizeof(a));
}

int UnixSignalHandler::setupUnixSignalHandlers()
{
    struct sigaction sighup, sigint, sigterm;

    sighup.sa_handler = UnixSignalHandler::hupSignalHandler;
    sigemptyset(&sighup.sa_mask);
    sighup.sa_flags = SA_RESTART;

    if (sigaction(SIGHUP, &sighup, 0) > 0)
    {
        return 1;
    }

    sigint.sa_handler = UnixSignalHandler::intSignalHandler;
    sigemptyset(&sigint.sa_mask);
    sigint.sa_flags = SA_RESTART;

    if (sigaction(SIGINT, &sigint, 0) > 0)
    {
        return 2;
    }

    sigterm.sa_handler = UnixSignalHandler::termSignalHandler;
    sigemptyset(&sigterm.sa_mask);
    sigterm.sa_flags = SA_RESTART;

    if (sigaction(SIGTERM, &sigterm, 0) > 0)
    {
        return 3;
    }

    return 0;
}

void UnixSignalHandler::handleSigHup()
{
    m_socketNotifierHup->setEnabled(false);
    char tmp;
    ::read(sighupFd[1], &tmp, sizeof(tmp));

    m_func();

    m_socketNotifierHup->setEnabled(true);
}

void UnixSignalHandler::handleSigInt()
{
    m_socketNotifierInt->setEnabled(false);
    char tmp;
    ::read(sigintFd[1], &tmp, sizeof(tmp));

    m_func();

    m_socketNotifierInt->setEnabled(true);
}

void UnixSignalHandler::handleSigTerm()
{
    m_socketNotifierTerm->setEnabled(false);
    char tmp;
    ::read(sigtermFd[1], &tmp, sizeof(tmp));

    m_func();

    m_socketNotifierTerm->setEnabled(true);
}
