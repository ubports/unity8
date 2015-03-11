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
 *
 */

#ifndef UNITY_INPUTWATCHER_H
#define UNITY_INPUTWATCHER_H

#include <QObject>
#include <QPointer>

/*
  Monitors the target object for input events to figure out whether it's pressed
  or not.
 */
class InputWatcher : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QObject* target READ target WRITE setTarget NOTIFY targetChanged)
    Q_PROPERTY(bool pressed READ pressed NOTIFY pressedChanged)
public:
    InputWatcher(QObject *parent = nullptr);

    QObject *target() const;
    void setTarget(QObject *value);

    bool pressed() const;

    bool eventFilter(QObject *watched, QEvent *event) override;

Q_SIGNALS:
    void targetChanged(QObject *value);
    void pressedChanged(bool value);

private:
    void setMousePressed(bool value);
    void setTouchPressed(bool value);

    bool m_mousePressed;
    bool m_touchPressed;
    QPointer<QObject> m_target;
};

#endif // UNITY_INPUTWATCHER_H
