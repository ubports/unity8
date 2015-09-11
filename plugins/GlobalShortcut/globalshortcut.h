/*
 * Copyright (C) 2015 Canonical, Ltd.
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

#ifndef GLOBALSHORTCUT_H
#define GLOBALSHORTCUT_H

#include <QVariant>
#include <QQuickWindow>
#include <QQuickItem>

/**
 * @brief The GlobalShortcut class
 *
 * QML component for registering a shortcut; the shortcut itself can be
 * specified either as a string ("Ctrl+Alt+L") or as an enum value
 * (Qt.ControlModifier|Qt.AltModifier|Qt.Key_L).
 *
 * When the shortcut is detected, the signal triggered() gets emitted.
 */
class GlobalShortcut: public QQuickItem
{
    Q_OBJECT
    /**
     * The shortcut itself
     */
    Q_PROPERTY(QVariant shortcut READ shortcut WRITE setShortcut NOTIFY shortcutChanged)
    /**
     * Whether the shortcut is active (true by default)
     */
    Q_PROPERTY(bool active READ isActive WRITE setActive NOTIFY activeChanged)

public:
    GlobalShortcut(QQuickItem *parent = nullptr);
    ~GlobalShortcut() = default;

    QVariant shortcut() const;
    void setShortcut(const QVariant &shortcut);

    bool isActive() const;
    void setActive(bool active);

protected:
    void componentComplete() override;
    void keyPressEvent(QKeyEvent * event) override;

Q_SIGNALS:
    void shortcutChanged(const QVariant &shortcut);
    /**
     * Emitted when a global keypress of @p shortcut is detected
     */
    void triggered(const QString &shortcut);
    void activeChanged(bool active);

private Q_SLOTS:
    void setupFilterOnWindow(QQuickWindow* window);

private:
    QVariant m_shortcut;
    bool m_active = true;
};


#endif // GLOBALSHORTCUT_H
