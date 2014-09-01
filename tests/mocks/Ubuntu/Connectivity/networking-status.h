/*
 * Copyright © 2014 Canonical Ltd.
 *
 * This program is free software: you can redistribute it and/or modify it
 * under the terms of the GNU Lesser General Public License version 3,
 * as published by the Free Software Foundation.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 */

#ifndef FAKE_NETWORKING_STATUS_H
#define FAKE_NETWORKING_STATUS_H

#include <QObject>
#include <QVector>

class Q_DECL_EXPORT NetworkingStatus : public QObject
{
    Q_OBJECT
    Q_DISABLE_COPY(NetworkingStatus)

    Q_ENUMS(Limitations)
    Q_ENUMS(Status)

    Q_PROPERTY(QVector<Limitations> limitations READ limitations NOTIFY limitationsChanged)
    Q_PROPERTY(Status status READ status NOTIFY statusChanged)
    Q_PROPERTY(bool online READ online NOTIFY onlineChanged)
    Q_PROPERTY(bool limitedBandwith READ limitedBandwith NOTIFY limitedBandwithChanged)

public:
    explicit NetworkingStatus(QObject *parent = 0);
    virtual ~NetworkingStatus();

    enum Limitations {
        Bandwith
    };

    enum Status {
        Offline,
        Connecting,
        Online
    };

    QVector<Limitations> limitations() const;
    Status status() const;
    bool online() const;
    bool limitedBandwith() const;

Q_SIGNALS:
    void limitationsChanged();
    void statusChanged(Status value);
    void onlineChanged(bool value);
    void limitedBandwithChanged(bool value);
};

Q_DECLARE_METATYPE(NetworkingStatus::Limitations)
Q_DECLARE_METATYPE(QVector<NetworkingStatus::Limitations>)
Q_DECLARE_METATYPE(NetworkingStatus::Status)

#endif // FAKE_NETWORKING_STATUS_H
