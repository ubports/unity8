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
 */

// This class just exists as a backend for the instantiable Qml objects to pull
// from.  It exists only for this mock plugin.

#ifndef MOCK_QOFONO_H
#define MOCK_QOFONO_H

#include <QObject>
#include <QMap>
#include <QStringList>

class MockQOfono : public QObject
{
    Q_OBJECT
    Q_PROPERTY(bool available READ available WRITE setAvailable NOTIFY availableChanged)
    Q_PROPERTY(bool ready READ ready WRITE setReady NOTIFY readyChanged)
    Q_PROPERTY(QStringList modems READ modems NOTIFY modemsChanged)

public:
    static MockQOfono *instance();
    ~MockQOfono();

    bool available() const;
    void setAvailable(bool available);
    bool ready() const;
    void setReady(bool ready);
    QStringList modems() const;

    Q_INVOKABLE void setModems(const QStringList &modems, const QList<bool> &present, const QList<bool> &ready);
    Q_INVOKABLE bool isModemPresent(const QString &modem);
    Q_INVOKABLE bool isModemReady(const QString &modem);

Q_SIGNALS:
    void availableChanged();
    void readyChanged();
    void modemsChanged();

private:
    explicit MockQOfono();

    bool m_available;
    bool m_ready;
    QMap<QString, QList<bool>> m_modems;
};

#endif // MOCK_QOFONO_H
