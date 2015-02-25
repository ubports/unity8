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

#ifndef MOCK_QOFONO_MANAGER_H
#define MOCK_QOFONO_MANAGER_H

#include <QObject>
#include <QStringList>

class MockQOfonoManager : public QObject
{
    Q_OBJECT
    Q_PROPERTY(bool available READ available NOTIFY availableChanged)
    Q_PROPERTY(QStringList modems READ modems NOTIFY modemsChanged)

public:
    explicit MockQOfonoManager(QObject *parent = 0);

    bool available() const;
    QStringList modems() const;

Q_SIGNALS:
    void availableChanged();
    void modemsChanged();

private Q_SLOTS:
    void maybeModemsChanged();
    void checkReady();
    void setModems();

private:
    bool m_modemsSet;
    bool m_startedSet;
};

#endif // MOCK_QOFONO_MANAGER_H
