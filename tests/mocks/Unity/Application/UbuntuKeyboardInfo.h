/*
 * Copyright (C) 2014-2015 Canonical, Ltd.
 *
 * This program is free software: you can redistribute it and/or modify it under
 * the terms of the GNU Lesser General Public License version 3, as published by
 * the Free Software Foundation.
 *
 * This program is distributed in the hope that it will be useful, but WITHOUT
 * ANY WARRANTY; without even the implied warranties of MERCHANTABILITY,
 * SATISFACTORY QUALITY, or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

#ifndef UBUNTU_KEYBOARD_INFO_H
#define UBUNTU_KEYBOARD_INFO_H

#include <QLocalSocket>
#include <QTimer>

class UbuntuKeyboardInfo : public QObject {
    Q_OBJECT
    Q_PROPERTY(qreal x READ x WRITE setX NOTIFY xChanged)
    Q_PROPERTY(qreal y READ y WRITE setY NOTIFY yChanged)
    Q_PROPERTY(qreal width READ width WRITE setWidth NOTIFY widthChanged)
    Q_PROPERTY(qreal height READ height WRITE setHeight NOTIFY heightChanged)
public:
    UbuntuKeyboardInfo(QObject *parent = 0);
    virtual ~UbuntuKeyboardInfo() {}
    qreal x() const { return m_x; }
    qreal y() const { return m_y; }
    qreal width() const { return m_width; }
    qreal height() const { return m_height; }

    // Just in the fake implementation
    void setX(qreal value);
    void setY(qreal value);
    void setWidth(qreal value);
    void setHeight(qreal value);

Q_SIGNALS:
    void xChanged(qreal x);
    void yChanged(qreal y);
    void widthChanged(qreal width);
    void heightChanged(qreal height);

private:
    QLocalSocket m_socket;
    qint32 m_x;
    qint32 m_y;
    qint32 m_width;
    qint32 m_height;
};

#endif // UBUNTU_KEYBOARD_INFO_H
