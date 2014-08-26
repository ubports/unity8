/*
 * Copyright 2013 Canonical Ltd.
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation; version 3.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 * Authors:
 *      Michael Zanetti <michael.zanetti@canonical.com>
 */

#ifndef MOCKLAUNCHERITEM_H
#define MOCKLAUNCHERITEM_H

#include <unity/shell/launcher/LauncherItemInterface.h>

class MockQuickListModel;

using namespace unity::shell::launcher;

class MockLauncherItem: public LauncherItemInterface
{
    Q_OBJECT
public:
    MockLauncherItem(const QString &appId, const QString& desktopFile, const QString& name, const QString& icon, QObject* parent = 0);

    QString appId() const;
    QString desktopFile() const;
    QString name() const;
    QString icon() const;

    bool pinned() const;
    void setPinned(bool pinned);

    bool running() const;
    void setRunning(bool running);

    bool recent() const;
    void setRecent(bool recent);

    int progress() const;
    void setProgress(int progress);

    int count() const;
    void setCount(int count);

    bool countVisible() const;
    void setCountVisible(bool countVisible);

    bool focused() const;
    void setFocused(bool focused);

    unity::shell::launcher::QuickListModelInterface *quickList() const;

private:
    QString m_appId;
    QString m_desktopFile;
    QString m_name;
    QString m_icon;
    bool m_pinned;
    bool m_running;
    bool m_recent;
    int m_progress;
    int m_count;
    bool m_countVisible;
    bool m_focused;
    MockQuickListModel *m_quickList;
};

#endif // MOCKLAUNCHERITEM_H
