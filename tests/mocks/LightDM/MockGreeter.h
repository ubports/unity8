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
 */

// The real, production, Greeter
#include <Greeter.h>

#ifndef MOCK_UNITY_GREETER_H
#define MOCK_UNITY_GREETER_H

class MockGreeter : public Greeter {
    Q_OBJECT

    Q_PROPERTY(QString mockMode READ mockMode WRITE setMockMode NOTIFY mockModeChanged)

public:
    QString mockMode() const;
    void setMockMode(QString mockMode);

Q_SIGNALS:
    void mockModeChanged(QString mode);
};

#endif // MOCK_UNITY_GREETER_H
