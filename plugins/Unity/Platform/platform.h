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
 */

#ifndef PLATFORM_H
#define PLATFORM_H

#include <QDBusInterface>

/**
 * @brief The Platform class
 *
 * Wrapper around platform detection support (org.freedesktop.hostname1)
 */
class Platform: public QObject
{
    Q_OBJECT
    /**
     * The chassis property
     *
     * Supported values include: "laptop", "computer", "handset" or "tablet"
     * For full list see: http://www.freedesktop.org/wiki/Software/systemd/hostnamed/
     */
    Q_PROPERTY(QString chassis READ chassis CONSTANT)
    /**
     * Whether the machine is an ordinary PC (desktop, laptop or server)
     */
    Q_PROPERTY(bool isPC READ isPC CONSTANT)

public:
    Platform(QObject *parent = nullptr);
    ~Platform() = default;

    QString chassis() const;
    bool isPC() const;

private Q_SLOTS:
    void init();

private:
    QDBusInterface m_iface;
    QString m_chassis;
    bool m_isPC;
};

#endif // PLATFORM_H
