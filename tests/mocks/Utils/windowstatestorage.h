/*
 * Copyright 2015 Canonical Ltd.
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation; version 3.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with this program. If not, see <http://www.gnu.org/licenses/>.
 */

#include <QObject>
#include <QVariantMap>
#include <QRect>

class WindowStateStorage: public QObject
{
    Q_OBJECT
    Q_PROPERTY(QVariantMap geometry READ geometry WRITE setGeometry NOTIFY geometryChanged)
    Q_ENUMS(WindowState)
public:
    enum WindowState {
        WindowStateNormal,
        WindowStateMaximized
    };
    WindowStateStorage(QObject *parent = 0);

    Q_INVOKABLE void saveState(const QString &windowId, WindowState state);
    Q_INVOKABLE WindowState getState(const QString &windowId, WindowState defaultValue);

    Q_INVOKABLE void saveGeometry(const QString &windowId, const QRect &rect);
    Q_INVOKABLE QRect getGeometry(const QString &windowId, const QRect &defaultValue);

    // Only in the mock, to easily restore a fresh state
    Q_INVOKABLE void clear();

Q_SIGNALS:
    void geometryChanged(const QVariantMap& geometry);

private:
    void setGeometry(const QVariantMap& geometry);
    QVariantMap geometry() const;

    QHash<QString, WindowState> m_state;
    QVariantMap m_geometry;
};
