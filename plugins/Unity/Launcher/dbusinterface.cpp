/*
 * Copyright 2014 Canonical Ltd.
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

#include "dbusinterface.h"
#include "launchermodel.h"
#include "launcheritem.h"

#include <QDBusArgument>
#include <QDBusConnection>
#include <QDBusMessage>
#include <QDebug>

DBusInterface::DBusInterface(LauncherModel *parent):
    UnityDBusVirtualObject("/com/canonical/Unity/Launcher", "com.canonical.Unity.Launcher", true, parent),
    m_launcherModel(parent)
{
}

QString DBusInterface::introspect(const QString &path) const
{
    /* This case we should just list the nodes */
    if (path == "/com/canonical/Unity/Launcher/" || path == "/com/canonical/Unity/Launcher") {
        QString nodes;

        // Add Refresh to introspect
        nodes = "<interface name=\"com.canonical.Unity.Launcher\">"
                "<method name=\"Refresh\"/>"
                "</interface>";

        // Add dynamic properties for launcher emblems
        for (int i = 0; i < m_launcherModel->rowCount(); i++) {
            nodes.append("<node name=\"");
            nodes.append(encodeAppId(m_launcherModel->get(i)->appId()));
            nodes.append("\"/>\n");
        }
        return nodes;
    }

    /* Should not happen, but let's handle it */
    if (!path.startsWith("/com/canonical/Unity/Launcher")) {
        return "";
    }

    /* Now we should be looking at a node */
    QString nodeiface =
        "<interface name=\"com.canonical.Unity.Launcher.Item\">"
            "<property name=\"count\" type=\"i\" access=\"readwrite\" />"
            "<property name=\"countVisible\" type=\"b\" access=\"readwrite\" />"
            "<property name=\"progress\" type=\"i\" access=\"readwrite\" />"
            "<method name=\"Alert\" />"
        "</interface>";
    return nodeiface;
}


QString DBusInterface::decodeAppId(const QString& path)
{
    QByteArray bytes = path.toUtf8();
    QByteArray decoded;

    for (int i = 0; i < bytes.size(); ++i) {
        char chr = bytes.at(i);

        if (chr == '_') {
            QString number;
            number.append(bytes.at(i+1));
            number.append(bytes.at(i+2));

            bool okay;
            char newchar = number.toUInt(&okay, 16);
            if (okay)
                decoded.append(newchar);

            i += 2;
        } else {
            decoded.append(chr);
        }
    }

    return QString::fromUtf8(decoded);
}

QString DBusInterface::encodeAppId(const QString& appId)
{
    QByteArray bytes = appId.toUtf8();
    QString encoded;

    for (int i = 0; i < bytes.size(); ++i) {
        uchar chr = bytes.at(i);

        if ((chr >= 'a' && chr <= 'z') ||
            (chr >= 'A' && chr <= 'Z') ||
            (chr >= '0' && chr <= '9'&& i != 0)) {
            encoded.append(chr);
        } else {
            QString hexval = QString("_%1").arg(chr, 2, 16, QChar('0'));
            encoded.append(hexval.toUpper());
        }
    }

    return encoded;
}

bool DBusInterface::handleMessage(const QDBusMessage& message, const QDBusConnection& connection)
{
    /* Check to make sure we're getting properties on our interface */
    if (message.type() != QDBusMessage::MessageType::MethodCallMessage) {
        return false;
    }

    /* Break down the path to just the app id */
    bool validpath = true;
    QString pathtemp = message.path();
    if (!pathtemp.startsWith("/com/canonical/Unity/Launcher/")) {
        validpath = false;
    }
    pathtemp.remove("/com/canonical/Unity/Launcher/");
    if (pathtemp.indexOf('/') >= 0) {
        validpath = false;
    }

    /* Find ourselves an appid */
    QString appid = decodeAppId(pathtemp);

    // First handle methods of the Launcher interface
    if (message.interface() == "com.canonical.Unity.Launcher") {
        if (message.member() == "Refresh") {
            QDBusMessage reply = message.createReply();
            Q_EMIT refreshCalled();
            return connection.send(reply);
        }
    } else if (message.interface() == "com.canonical.Unity.Launcher.Item") {
        // Handle methods of the Launcher-Item interface
        if (message.member() == "Alert" && validpath) {
            QDBusMessage reply = message.createReply();
            Q_EMIT alertCalled(appid);
            return connection.send(reply);
        }
    }

    // Now handle dynamic properties (for launcher emblems)
    if (message.interface() != "org.freedesktop.DBus.Properties") {
        return false;
    }

    if (message.member() == "Get" && (message.arguments().count() != 2 || message.arguments()[0].toString() != "com.canonical.Unity.Launcher.Item")) {
        return false;
    }

    if (message.member() == "Set" && (message.arguments().count() != 3 || message.arguments()[0].toString() != "com.canonical.Unity.Launcher.Item")) {
        return false;
    }

    if (!validpath) {
        return false;
    }

    int index = m_launcherModel->findApplication(appid);
    LauncherItem *item = static_cast<LauncherItem*>(m_launcherModel->get(index));

    QVariantList retval;
    if (message.member() == "Get") {
        QString cachedString = message.arguments()[1].toString();
        if (!item) {
            return false;
        }
        if (cachedString == "count") {
            retval.append(QVariant::fromValue(QDBusVariant(item->count())));
        } else if (cachedString == "countVisible") {
            retval.append(QVariant::fromValue(QDBusVariant(item->countVisible())));
        } else if (cachedString == "progress") {
            retval.append(QVariant::fromValue(QDBusVariant(item->progress())));
        }
    } else if (message.member() == "Set") {
        QString cachedString = message.arguments()[1].toString();
        if (cachedString == "count") {
            int newCount = message.arguments()[2].value<QDBusVariant>().variant().toInt();
            if (!item || newCount != item->count()) {
                Q_EMIT countChanged(appid, newCount);
                notifyPropertyChanged("com.canonical.Unity.Launcher.Item", encodeAppId(appid), "count", QVariant(newCount));
            }
        } else if (cachedString == "countVisible") {
            bool newVisible = message.arguments()[2].value<QDBusVariant>().variant().toBool();
            if (!item || newVisible != item->countVisible()) {
                Q_EMIT countVisibleChanged(appid, newVisible);
                notifyPropertyChanged("com.canonical.Unity.Launcher.Item", encodeAppId(appid), "countVisible", newVisible);
            }
        } else if (cachedString == "progress") {
            int newProgress = message.arguments()[2].value<QDBusVariant>().variant().toInt();
            if (!item || newProgress != item->progress()) {
                Q_EMIT progressChanged(appid, newProgress);
                notifyPropertyChanged("com.canonical.Unity.Launcher.Item", encodeAppId(appid), "progress", QVariant(newProgress));
            }
        }
    } else if (message.member() == "GetAll") {
        if (item) {
            QVariantMap all;
            all.insert("count", item->count());
            all.insert("countVisible", item->countVisible());
            all.insert("progress", item->progress());
            retval.append(all);
        }
    } else {
        return false;
    }

    QDBusMessage reply = message.createReply(retval);
    return connection.send(reply);
}
