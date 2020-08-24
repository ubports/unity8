/*
 * Copyright (C) 2019 UBports Foundation.
 * Author(s): Marius Gripsgard <marius@ubports.com>
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

#include <QObject>

class XdgWatcher: public QObject
{
    Q_OBJECT
public:
    XdgWatcher(QObject* parent = nullptr);

    // testing
    static XdgWatcher* instance();
    static const QString stripAppIdVersion(const QString rawAppID);
    void addMockApp(const QString &appId);
    void removeMockApp(const QString &appId);
Q_SIGNALS:
    void appAdded(const QString &appId);
    void appRemoved(const QString &appId);
    void appInfoChanged(const QString &appId);

private:
    static QStringList s_list;
    static XdgWatcher *s_xinstance;
};
