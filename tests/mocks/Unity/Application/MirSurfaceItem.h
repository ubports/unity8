/*
 * Copyright (C) 2014 Canonical, Ltd.
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

#ifndef MIRSURFACEITEM_H
#define MIRSURFACEITEM_H

#include <QQuickPaintedItem>
#include <QImage>

class MirSurfaceItem : public QQuickPaintedItem
{
    Q_OBJECT
    Q_ENUMS(Type)
    Q_ENUMS(State)

    Q_PROPERTY(Type type READ type NOTIFY typeChanged)
    Q_PROPERTY(State state READ state NOTIFY stateChanged)
    Q_PROPERTY(QString name READ name NOTIFY nameChanged)

public:
    enum Type {
        Normal,
        Utility,
        Dialog,
        Overlay,
        Freestyle,
        Popover,
        InputMethod,
    };

    enum State {
        Unknown,
        Restored,
        Minimized,
        Maximized,
        VertMaximized,
        /* SemiMaximized, */
        Fullscreen,
    };

    explicit MirSurfaceItem(const QString& name,
                            Type type,
                            State state,
                            const QUrl& screenshot,
                            QQuickItem *parent = 0);

    //getters
    Type type() const { return m_type; }
    State state() const { return m_state; }
    QString name() const { return m_name; }

    void setState(State newState);

    Q_INVOKABLE void release() {}

    void paint(QPainter * painter) override;

    void touchEvent(QTouchEvent * event) override;

Q_SIGNALS:
    void typeChanged(Type);
    void stateChanged(State);
    void nameChanged(QString);

    void inputMethodRequested();
    void inputMethodDismissed();

private Q_SLOTS:
    void onFocusChanged();

protected:
    const QImage &screenshotImage() { return m_img; }

private:

    const QString m_name;
    const Type m_type;
    State m_state;
    const QImage m_img;

    bool m_haveInputMethod;
};

Q_DECLARE_METATYPE(MirSurfaceItem*)

#endif // MIRSURFACEITEM_H
