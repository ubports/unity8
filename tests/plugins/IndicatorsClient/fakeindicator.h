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
 * Authors:
 *      Renato Araujo Oliveira Filho <renato@canonical.com>
 *      Nick Dedekind <nick.dedekind@canonical.com>
 */

#ifndef FAKE_INDICATORCLIENT_H
#define FAKE_INDICATORCLIENT_H

#include "indicatorclient_common.h"

class FakeIndicatorClient : public IndicatorClientCommon
{
    Q_OBJECT
    Q_PROPERTY(int initializedCount READ initializedCount)
public:
    FakeIndicatorClient(QObject *parent=0)
    : IndicatorClientCommon(parent)
    , m_initializedCount(0)
    {
    }
    void init(const QSettings& settings)
    {
        IndicatorClientCommon::init(settings);
        m_initializedCount++;
    }
    int initializedCount() const { return m_initializedCount; }
    void shutdown() { m_initializedCount--; }

  private:
    int m_initializedCount;
};


#define FAKE_INDICATOR(number, title) \
  class FakeIndicatorClient##number : public FakeIndicatorClient \
  { \
  public: \
      FakeIndicatorClient##number(QObject *parent=0) \
      : FakeIndicatorClient(parent) \
      { \
          setTitle(title); \
          setPriority(number); \
      } \
  };


#endif
