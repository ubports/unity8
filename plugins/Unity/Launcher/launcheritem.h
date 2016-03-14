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

#ifndef LAUNCHERITEM_H
#define LAUNCHERITEM_H

#include "quicklistmodel.h"

#include <unity/shell/launcher/LauncherItemInterface.h>

class QuickListModel;

using namespace unity::shell::launcher;

class LauncherItem: public LauncherItemInterface
{
    Q_OBJECT
public:
    LauncherItem(const QString &appId, const QString &name, const QString &icon, QObject *parent);

    QString appId() const override;
    QString name() const override;
    QString icon() const override;
    bool pinned() const override;
    bool running() const override;
    bool recent() const override;
    int progress() const override;
    int count() const override;
    bool countVisible() const override;
    bool focused() const override;
    bool alerting() const override;

    unity::shell::launcher::QuickListModelInterface *quickList() const override;

private:
    void setName(const QString &name);
    void setIcon(const QString &icon);
    void setPinned(bool pinned);
    void setRunning(bool running);
    void setRecent(bool recent);
    void setProgress(int progress);
    void setCount(int count);
    void setCountVisible(bool countVisible);
    void setFocused(bool focused);
    void setAlerting(bool alerting);

private:
    QString m_appId;
    QString m_name;
    QString m_icon;
    bool m_pinned;
    bool m_running;
    bool m_recent;
    int m_progress;
    int m_count;
    bool m_countVisible;
    bool m_focused;
    bool m_alerting;
    QuickListModel *m_quickList;
    QuickListEntry m_quitAction;

    friend class LauncherModel;
};

#endif // LAUNCHERITEM_H
