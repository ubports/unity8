/*
 * Copyright 2015 Canonical Ltd.
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
 *      Mirco Mueller <mirco.mueller@canonical.com>
 */

#include "MockNotification.h"

#include <QDebug>

struct MockNotificationPrivate {
    int id;
    QString summary;
    QString body;
    int value;
    MockNotification::Type type;
    QString icon;
    QString secondaryIcon;
    QStringList actions;
    ActionModel* actionsModel;
    QVariantMap hints;
    bool fullscreen = false;
};

MockNotification::MockNotification(QObject *parent) : QObject(parent), p(new MockNotificationPrivate()) {
    p->actionsModel = new ActionModel();
}

MockNotification::~MockNotification() {
    delete p->actionsModel;
}

QString MockNotification::getSummary() const {
    return p->summary;
}

void MockNotification::setSummary(const QString &summary) {
    if(p->summary != summary) {
        p->summary = summary;
        Q_EMIT summaryChanged(p->summary);
        Q_EMIT dataChanged(p->id);
    }
}

QString MockNotification::getBody() const {
    return p->body;
}

void MockNotification::setBody(const QString &body) {
    if(p->body != body) {
        p->body = body;
        Q_EMIT bodyChanged(p->body);
        Q_EMIT dataChanged(p->id);
    }
}

int MockNotification::getID() const {
    return p->id;
}

void MockNotification::setID(const int id) {
    p->id = id;
}

int MockNotification::getValue() const {
    return p->value;
}

void MockNotification::setValue(int value) {
    if(p->value != value) {
        p->value = value;
        Q_EMIT valueChanged(p->value);
        Q_EMIT dataChanged(p->id);
    }
}

QString MockNotification::getIcon() const {
    return p->icon;
}

void MockNotification::setIcon(const QString &icon) {
    if (icon.startsWith(" ") || icon.size() == 0) {
        p->icon = nullptr;
    }
    else {
        p->icon = icon;

        if (icon.indexOf("/") == -1) {
            p->icon.prepend("image://theme/");
        }
    }

    Q_EMIT iconChanged(p->icon);
    Q_EMIT dataChanged(p->id);
}

QString MockNotification::getSecondaryIcon() const {
    return p->secondaryIcon;
}

void MockNotification::setSecondaryIcon(const QString &secondaryIcon) {
    if (secondaryIcon.startsWith(" ") || secondaryIcon.size() == 0) {
        p->secondaryIcon = nullptr;
    }
    else {
        p->secondaryIcon = secondaryIcon;

        if (secondaryIcon.indexOf("/") == -1) {
            p->secondaryIcon.prepend("image://theme/");
        }
    }

    Q_EMIT secondaryIconChanged(p->secondaryIcon);
    Q_EMIT dataChanged(p->id);
}

MockNotification::Type MockNotification::getType() const {
    return p->type;
}

void MockNotification::setType(Type type) {
    if(p->type != type) {
        p->type = type;
        Q_EMIT typeChanged(p->type);
    }
}

ActionModel* MockNotification::getActions() const {
    return p->actionsModel;
}

QStringList MockNotification::rawActions() const {
    return p->actions;
}

void MockNotification::setActions(const QStringList &actions) {
    if(p->actions != actions) {
        p->actions = actions;
        Q_EMIT actionsChanged(p->actions);

        for (int i = 0; i < p->actions.size(); i += 2) {
            p->actionsModel->append(p->actions[i], p->actions[i+1]);
        }
    }
}

QVariantMap MockNotification::getHints() const {
    return p->hints;
}

void MockNotification::setHints(const QVariantMap& hints) {
    if (p->hints != hints) {
        p->hints = hints;
        Q_EMIT hintsChanged(p->hints);
    }
}

void MockNotification::invokeAction(const QString &action) {
    for(int i=0; i<p->actions.size(); i++) {
        if(p->actions[i] == action) {
            Q_EMIT actionInvoked(action);
            qDebug() << "Info: invoked action" << action;
            return;
        }
    }
    fprintf(stderr, "Error: tried to invoke action not in actionList.\n");
}

void MockNotification::close() {
    Q_EMIT completed(p->id);
}

bool MockNotification::fullscreen() const
{
    return p->fullscreen;
}

void MockNotification::setFullscreen(bool fullscreen)
{
    if (p->fullscreen == fullscreen)
        return;

    p->fullscreen = fullscreen;
    Q_EMIT fullscreenChanged(fullscreen);
}
