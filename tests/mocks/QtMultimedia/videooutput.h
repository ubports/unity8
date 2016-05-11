/*
 * Copyright (C) 2016 Canonical, Ltd.
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

#ifndef VIDEOOUTPUT_H
#define VIDEOOUTPUT_H

#include <QQuickItem>
#include <QPointer>
class QQmlComponent;

class VideoOutput : public QQuickItem
{
    Q_OBJECT
    Q_PROPERTY(QObject* source READ source WRITE setSource NOTIFY sourceChanged)
public:
    explicit VideoOutput(QQuickItem *parent = 0);

    QObject *source() const { return m_source.data(); }
    void setSource(QObject *source);

    void itemChange(ItemChange change, const ItemChangeData & value);

Q_SIGNALS:
    void sourceChanged();

protected Q_SLOTS:
    void onComponentStatusChanged(QQmlComponent::Status status);
    void updateProperties();

private:
    void createQmlContentItem();
    void printComponentErrors();

    QPointer<QObject> m_source;
    QQmlComponent* m_qmlContentComponent;
    QQuickItem* m_qmlItem;
};

#endif // VIDEOOUTPUT_H
