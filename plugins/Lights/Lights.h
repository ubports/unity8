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
 * Author: Renato Araujo Oliveira Filho <renato.filho@canonical.com>
 */

#ifndef UNITY_LIGHTS_H
#define UNITY_LIGHTS_H

#include <QtCore/QObject>

struct light_device_t;

class Lights: public QObject
{
    Q_OBJECT
    Q_ENUMS(State)
    Q_PROPERTY(State state READ state  WRITE setState NOTIFY stateChanged)

public:
    enum State {
        Off,
        On,
    };

    explicit Lights(QObject *parent = 0);
    ~Lights();

    void setState(State newState);
    State state() const;

Q_SIGNALS:
    void stateChanged(State newState);

private:
    State m_state;
    light_device_t* m_lightDevice;

    bool init();
    void turnOff();
    void turnOn();
};

#endif
