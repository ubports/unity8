#include "dbusinterface.h"
#include "launchermodel.h"
#include "launcheritem.h"

#include <QDBusArgument>
#include <QDBusConnection>
#include <QDBusMessage>
#include <QDebug>

DBusInterface::DBusInterface(LauncherModel *parent):
    QDBusVirtualObject(parent),
    m_launcherModel(parent)
{
    /* Set up ourselves on DBus */
    QDBusConnection con = QDBusConnection::sessionBus();
    if (!con.registerService("com.canonical.Unity.Launcher")) {
        qWarning() << "Unable to register launcher name";
    }
    if (!con.registerVirtualObject("/com/canonical/Unity/Launcher", this, QDBusConnection::VirtualObjectRegisterOption::SubPath)) {
        qWarning() << "Unable to register launcher object";
    }
}

DBusInterface::~DBusInterface()
{
    /* Remove oursevles from DBus */
    QDBusConnection con = QDBusConnection::sessionBus();
    con.unregisterService("com.canonical.Unity.Launcher");
    con.unregisterObject("/com/canonical/Unity/Launcher");
}

QString DBusInterface::introspect(const QString &path) const
{
    qDebug() << "introspecting" << path;
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

    // First handle methods of the Launcher interface
    if (message.interface() == "com.canonical.Unity.Launcher") {
        if (message.member() == "Refresh") {
            QDBusMessage reply = message.createReply();
            Q_EMIT refreshCalled();
            return connection.send(reply);
        }
    }

    // Now handle dynamic properties (for launcher emblems)
    if (message.interface() != "org.freedesktop.DBus.Properties") {
        return false;
    }

    if (message.member() != "GetAll" && message.arguments()[0].toString() != "com.canonical.Unity.Launcher.Item") {
        return false;
    }

    /* Break down the path to just the app id */
    QString pathtemp = message.path();
    if (!pathtemp.startsWith("/com/canonical/Unity/Launcher/")) {
        return false;
    }
    pathtemp.remove("/com/canonical/Unity/Launcher/");
    if (pathtemp.indexOf('/') >= 0) {
        return false;
    }

    /* Find ourselves an appid */
    QString appid = decodeAppId(pathtemp);
    int index = m_launcherModel->findApplication(appid);
    LauncherItem *item = static_cast<LauncherItem*>(m_launcherModel->get(index));

    QVariantList retval;
    if (message.member() == "Get") {
        if (!item) {
            return false;
        }
        if (message.arguments()[1].toString() == "count") {
            retval.append(QVariant::fromValue(QDBusVariant(item->count())));
        } else if (message.arguments()[1].toString() == "countVisible") {
            retval.append(QVariant::fromValue(QDBusVariant(item->countVisible())));
        }
    } else if (message.member() == "Set") {
        if (message.arguments()[1].toString() == "count") {
            int newCount = message.arguments()[2].value<QDBusVariant>().variant().toInt();
            if (!item || newCount != item->count()) {
                Q_EMIT countChanged(appid, newCount);
                emitPropChangedDbus(appid, "count", QVariant(newCount));
            }
        } else if (message.arguments()[1].toString() == "countVisible") {
            bool newVisible = message.arguments()[2].value<QDBusVariant>().variant().toBool();
            if (!item || newVisible != item->countVisible()) {
                Q_EMIT countVisibleChanged(appid, newVisible);
                emitPropChangedDbus(appid, "countVisible", newVisible);
            }
        }
    } else if (message.member() == "GetAll") {
        if (item) {
            QVariantMap all;
            all.insert("count", item->count());
            all.insert("countVisible", item->count());
            retval.append(all);
        }
    } else {
        return false;
    }

    QDBusMessage reply = message.createReply(retval);
    return connection.send(reply);
}

void DBusInterface::emitPropChangedDbus(const QString& appId, const QString& property, const QVariant &value)
{
    QString path("/com/canonical/Unity/Launcher/");
    path.append(encodeAppId(appId));

    QDBusMessage message = QDBusMessage::createSignal(path, "org.freedesktop.DBus.Properties", "PropertiesChanged");

    QList<QVariant> arguments;
    QVariantHash changedprops;
    changedprops[property] = QVariant::fromValue(QDBusVariant(value));
    QVariantList deletedprops;

    arguments.append(changedprops);
    arguments.append(deletedprops);

    message.setArguments(arguments);

    QDBusConnection con = QDBusConnection::sessionBus();
    con.send(message);
}
