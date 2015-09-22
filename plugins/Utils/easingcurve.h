/*
 * Copyright 2014 Canonical Ltd.
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
 *
 * Authors: Michael Zanetti <michael.zanetti@canonical.com>
*/

#ifndef EASINGCURVE_H
#define EASINGCURVE_H

#include <QObject>
#include <QEasingCurve>

/**
 * @brief The EasingCurve class
 *
 * This class exposes the QEasingCurve C++ API to QML.
 * This is useful for user interactive animations. While the QML Animation types
 * all require a "from", "to" and "duration", this one is based on "period" and
 * "progress". So you can control the position of the animation by changing the
 * progress, also going back and forward in the aimation. Depending on the type
 * of the easing curve, value will return the transformed progress.
 */

class EasingCurve: public QObject
{
    Q_OBJECT
    Q_ENUMS(QEasingCurve::Type)
    Q_PROPERTY(QEasingCurve::Type type READ type WRITE setType NOTIFY typeChanged)
    Q_PROPERTY(qreal period READ period WRITE setPeriod NOTIFY periodChanged)
    Q_PROPERTY(qreal progress READ progress WRITE setProgress NOTIFY progressChanged)
    Q_PROPERTY(qreal value READ value NOTIFY progressChanged)

public:
    EasingCurve(QObject *parent = 0);

    QEasingCurve::Type type() const;
    void setType(const QEasingCurve::Type &type);

    qreal period() const;
    void setPeriod(qreal period);

    qreal progress() const;
    void setProgress(qreal progress);

    qreal value() const;

Q_SIGNALS:
    void typeChanged();
    void periodChanged();
    void progressChanged();

private:
    QEasingCurve m_easingCurve;
    qreal m_progress;
    qreal m_value;
};

#endif
