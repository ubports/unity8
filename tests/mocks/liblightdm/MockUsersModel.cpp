/*
 * Copyright (C) 2013-2016 Canonical, Ltd.
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
 * Author: Michael Terry <michael.terry@canonical.com>
 */

// LightDM currently is Qt4 compatible, and so doesn't define setRoleNames.
// To use the same method of setting role name that it does, we
// set our compatibility to Qt4 here too.
#define QT_DISABLE_DEPRECATED_BEFORE QT_VERSION_CHECK(4, 0, 0)

#include "MockController.h"
#include "MockUsersModel.h"
#include <QDir>
#include <QIcon>

namespace QLightDM
{

class Entry
{
public:
    QString username;
    QString real_name;
    QString background;
    QString layouts;
    bool is_active;
    bool has_messages;
    QString session;
    uid_t uid;
};

class UsersModelPrivate
{
public:
    QList<Entry> entries;
};

UsersModel::UsersModel(QObject *parent)
    : QAbstractListModel(parent)
    , d_ptr(new UsersModelPrivate)
{
    // Extend roleNames (we want to keep the "display" role)
    QHash<int, QByteArray> roles = roleNames();
    roles[NameRole] = "name";
    roles[RealNameRole] = "realName";
    roles[LoggedInRole] = "loggedIn";
    roles[BackgroundRole] = "background";
    roles[BackgroundPathRole] = "backgroundPath";
    roles[SessionRole] = "session";
    roles[HasMessagesRole] = "hasMessages";
    roles[ImagePathRole] = "imagePath";
    roles[UidRole] = "uid";
    setRoleNames(roles);

    connect(MockController::instance(), &MockController::userModeChanged,
            this, &UsersModel::resetEntries);
    resetEntries();
}

UsersModel::~UsersModel()
{
    delete d_ptr;
}

int UsersModel::rowCount(const QModelIndex &parent) const
{
    Q_D(const UsersModel);

    if (parent.isValid()) {
        return 0;
    } else { // parent is root
        return d->entries.size();
    }
}

QVariant UsersModel::data(const QModelIndex &index, int role) const
{
    Q_D(const UsersModel);

    if (!index.isValid()) {
        return QVariant();
    }

    int row = index.row();
    switch (role) {
    case Qt::DisplayRole:
        return d->entries[row].real_name;
    case Qt::DecorationRole:
        return QIcon();
    case UsersModel::NameRole:
        return d->entries[row].username;
    case UsersModel::RealNameRole:
        return d->entries[row].real_name;
    case UsersModel::SessionRole:
        return d->entries[row].session;
    case UsersModel::LoggedInRole:
        return d->entries[row].is_active;
    case UsersModel::BackgroundRole:
        return QPixmap(d->entries[row].background);
    case UsersModel::BackgroundPathRole:
        return d->entries[row].background;
    case UsersModel::HasMessagesRole:
        return d->entries[row].has_messages;
    case UsersModel::ImagePathRole:
        return "";
    case UsersModel::UidRole:
        return d->entries[row].uid;
    default:
        return QVariant();
    }
}

void UsersModel::resetEntries()
{
    Q_D(UsersModel);

    beginResetModel();

    QString userMode = MockController::instance()->userMode();

    if (userMode == "single") {
        d->entries = {{"no-password", "No Password", 0, 0, false, false, "ubuntu", 0}};
    } else if (userMode == "single-passphrase") {
        d->entries = {{"has-password", "Has Password", 0, 0, false, false, "ubuntu", 0}};
    } else if (userMode == "single-pin") {
        d->entries = {{"has-pin", "Has PIN", 0, 0, false, false, "ubuntu", 0}};
    } else if (userMode == "full") {
        d->entries = {
            { "has-password",      "Has Password", 0, 0, false, false, "ubuntu", 0 },
            { "has-pin",           "Has PIN",      0, 0, false, false, "ubuntu", 0 },
            { "different-prompt",  "Different Prompt", 0, 0, false, false, "ubuntu", 0 },
            { "no-password",       "No Password", 0, 0, false, false, "ubuntu", 0 },
            { "auth-error",        "Auth Error", 0, 0, false, false, "ubuntu", 0 },
            { "two-factor",        "Two Factor", 0, 0, false, false, "ubuntu", 0 },
            { "info-prompt",       "Info Prompt", 0, 0, false, false, "ubuntu", 0 },
            { "html-info-prompt",  "HTML Info Prompt", 0, 0, false, false, "ubuntu", 0 },
            { "long-info-prompt",  "Long Info Prompt", 0, 0, false, false, "ubuntu", 0 },
            { "wide-info-prompt",  "Wide Info Prompt", 0, 0, false, false, "ubuntu", 0 },
            { "multi-info-prompt", "Multi Info Prompt", 0, 0, false, false, "ubuntu", 0 },
            { "long-name",         "Long name (far far too long to fit, seriously this would never fit on the screen, you will never see this part of the name)", 0, 0, false, false, "ubuntu", 0 },
            { "color-background",  "Color Background", "#E95420", 0, false, false, "ubuntu", 0 },
            // white and black are a bit redundant, but useful for manually testing if UI is still readable
            { "white-background",  "White Background", "#ffffff", 0, false, false, "ubuntu", 0 },
            { "black-background",  "Black Background", "#000000", 0, false, false, "ubuntu", 0 },
            { "no-background",     "No Background", "", 0, false, false, "ubuntu", 0 },
            { "unicode",           "가나다라마", 0, 0, false, false, "ubuntu", 0 },
            { "no-response",       "No Response", 0, 0, false, false, "ubuntu", 0 },
            { "empty-name",        "", 0, 0, false, false, "ubuntu", 0 },
            { "active",            "Active Account", 0, 0, true, false, "ubuntu", 0 },
        };
    }

    // Assign uids in a loop, just to avoid having to muck with them when
    // adding or removing test users.
    for (int i = 0; i < d->entries.size(); i++) {
        d->entries[i].uid = i + 1;
    }

    // Assign backgrounds
    QDir backgroundDir("/usr/share/backgrounds");
    QStringList backgrounds = backgroundDir.entryList(QDir::Files);
    if (!backgrounds.empty()) {
        for (int i = 0; i < d->entries.size(); i++) {
            if (d->entries[i].background.isNull()) {
                d->entries[i].background = backgroundDir.filePath(backgrounds[i % backgrounds.size()]);
            }
        }
    }

    endResetModel();
}

QObject *UsersModel::mock()
{
    return MockController::instance();
}

}
