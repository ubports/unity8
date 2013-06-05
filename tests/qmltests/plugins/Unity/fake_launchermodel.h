/*
 * Copyright (C) 2011 Canonical, Ltd.
 *
 * Authors:
 *  Michael Zanetti <michael.zanetti@canonical.com>
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

#include <QAbstractListModel>

class LauncherItem;

class LauncherModel: public QAbstractListModel
{
   Q_OBJECT

public:
    enum Roles {
        RoleDesktopFile = Qt::UserRole,
        RoleName,
        RoleIcon,
        RoleFavorite,
        RoleRunning
    };

    LauncherModel(QObject *parent = 0);
    ~LauncherModel();

    int rowCount(const QModelIndex &parent) const;

    QVariant data(const QModelIndex &index, int role) const;

    Q_INVOKABLE LauncherItem* get(int index) const;
    Q_INVOKABLE void move(int oldIndex, int newIndex);

    QHash<int, QByteArray> roleNames() const;

private:
    QList<LauncherItem*> m_list;
};

class LauncherItem: public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString desktopFile READ desktopFile CONSTANT)
    Q_PROPERTY(QString name READ name CONSTANT)
    Q_PROPERTY(QString icon READ icon CONSTANT)
    Q_PROPERTY(bool favorite READ favorite WRITE setFavorite NOTIFY favoriteChanged)
    Q_PROPERTY(bool running READ running WRITE setRunning NOTIFY runningChanged)

public:
    LauncherItem(const QString &desktopFile, const QString &name, const QString &icon, QObject *parent = 0);

    QString desktopFile() const;

    QString name() const;
    QString icon() const;

    bool favorite() const;
    void setFavorite(bool favorite);

    bool running() const;
    void setRunning(bool running);

Q_SIGNALS:
    void favoriteChanged(bool favorite);
    void runningChanged(bool running);

private:
    QString m_desktopFile;
    QString m_name;
    QString m_icon;
    bool m_favorite;
    bool m_running;
};
