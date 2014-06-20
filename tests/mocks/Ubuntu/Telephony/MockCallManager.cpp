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

#include "MockCallManager.h"

MockCallManager::MockCallManager(QObject *parent)
    : QObject(parent)
    , m_foregroundCall(nullptr)
    , m_backgroundCall(nullptr)
    , m_callIndicatorVisible(false)
{
}

MockCallManager *MockCallManager::instance()
{
    static MockCallManager* manager = new MockCallManager();
    return manager;
}

QObject* MockCallManager::foregroundCall() const
{
    return m_foregroundCall;
}

void MockCallManager::setForegroundCall(QObject* foregroundCall)
{
    if(m_foregroundCall != foregroundCall){
        m_foregroundCall = foregroundCall;
        Q_EMIT foregroundCallChanged();
        Q_EMIT hasCallsChanged();
    }
}

QObject* MockCallManager::backgroundCall() const
{
    return m_backgroundCall;
}

void MockCallManager::setBackgroundCall(QObject* backgroundCall)
{
    if(m_backgroundCall != backgroundCall){
        m_backgroundCall = backgroundCall;
        Q_EMIT backgroundCallChanged();
        Q_EMIT hasCallsChanged();
    }
}

bool MockCallManager::hasCalls() const
{
    return m_foregroundCall || m_backgroundCall;
}


bool MockCallManager::callIndicatorVisible() const
{
    return m_callIndicatorVisible;
}

void MockCallManager::setCallIndicatorVisible(bool callIndicatorVisible)
{
    if(m_callIndicatorVisible != callIndicatorVisible){
        m_callIndicatorVisible = callIndicatorVisible;
        Q_EMIT callIndicatorVisibleChanged();
    }
}
