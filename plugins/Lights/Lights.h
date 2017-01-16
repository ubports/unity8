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
#include <QtGui/QColor>

struct light_device_t;

class Lights: public QObject
{
    Q_OBJECT
    Q_PROPERTY(State state READ state  WRITE setState NOTIFY stateChanged)
    Q_PROPERTY(QColor color READ color WRITE setColor NOTIFY colorChanged)
    Q_PROPERTY(int onMillisec READ onMillisec WRITE setOnMillisec NOTIFY onMillisecChanged)
    Q_PROPERTY(int offMillisec READ offMillisec WRITE setOffMillisec NOTIFY offMillisecChanged)

public:
    enum State {
        Off,
        On,
    };
    Q_ENUM(State)

    explicit Lights(QObject *parent = 0);
    ~Lights();

    void setState(State newState);
    State state() const;

    void setColor(const QColor &color);
    QColor color() const;

    int onMillisec() const;
    void setOnMillisec(int onMs);

    int offMillisec() const;
    void setOffMillisec(int offMs);

Q_SIGNALS:
    void stateChanged(State newState);
    void colorChanged(const QColor &color);
    void onMillisecChanged(int onMs);
    void offMillisecChanged(int offMs);

private:
    light_device_t* m_lightDevice;
    QColor m_color;
    State m_state;
    int m_onMs;
    int m_offMs;

    bool init();
    void turnOff();
    void turnOn();
};

#endif
