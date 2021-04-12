/*
 * Copyright (C) 2014 Canonical, Ltd.
 *
 * This program is free software: you can redistribute it and/or modify it under
 * the terms of the GNU Lesser General Public License version 3, as published by
 * the Free Software Foundation.
 *
 * This program is distributed in the hope that it will be useful, but WITHOUT
 * ANY WARRANTY; without even the implied warranties of MERCHANTABILITY,
 * SATISFACTORY QUALITY, or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

#ifndef ORIENTATIONLOCK_H
#define ORIENTATIONLOCK_H

#include <gio/gio.h>
#include <QtCore/QObject>

/**
 * @brief The OrientationLock class exports orientation lock related properties to QML
 * It has two properties:
 *    - readonly boolean with the Orientation lock property state
 *    - Qt::ScreenOrientation to save the locked orientation state across Sessions (only relevant if lock is true)
 */
class OrientationLock : public QObject
{
    Q_OBJECT

    Q_PROPERTY(bool enabled READ enabled NOTIFY enabledChanged)
    Q_PROPERTY(Qt::ScreenOrientation savedOrientation READ savedOrientation WRITE setSavedOrientation
                   NOTIFY savedOrientationChanged)

public:
    explicit OrientationLock(QObject *parent = 0);
    ~OrientationLock();

    bool enabled() const;
    Qt::ScreenOrientation savedOrientation() const;
    void setSavedOrientation(const Qt::ScreenOrientation orientation);

Q_SIGNALS:
    void enabledChanged();
    void savedOrientationChanged();

private Q_SLOTS:
    static void onEnabledChangedProxy(GSettings *settings, const gchar *key, gpointer data);
    void onEnabledChanged();

private:
    GSettings *m_systemSettings;

    bool m_enabled;
    Qt::ScreenOrientation m_savedOrientation;
};

#endif // ORIENTATIONLOCK_H
