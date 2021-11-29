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
 *      Nick Dedekind <nick.dedekind@canonical.com>
 */

#ifndef LOMIRIMENUMODELSTACK_H
#define LOMIRIMENUMODELSTACK_H

#include "lomiriindicatorsglobal.h"

#include <QObject>
#include <QList>

class LomiriMenuModelEntry;
class AyatanaMenuModel;

// A LIFO queue for storing the current submenu of an AyatanaMenuModel.
// The root menu model is set as the head, and each subsiquent submenu that is
// opened can be pushed onto the queue.
// The tail is set to the last item on the queue
// Popping the queue will remove the last entry, and the tail be updated to the last item.
class LOMIRIINDICATORS_EXPORT LomiriMenuModelStack : public QObject
{
    Q_OBJECT
    Q_PROPERTY(AyatanaMenuModel* head READ head WRITE setHead NOTIFY headChanged)
    Q_PROPERTY(AyatanaMenuModel* tail READ tail NOTIFY tailChanged)
    Q_PROPERTY(int count READ count NOTIFY countChanged)
public:
    LomiriMenuModelStack(QObject*parent=nullptr);
    ~LomiriMenuModelStack();

    AyatanaMenuModel* head() const;
    void setHead(AyatanaMenuModel* model);

    AyatanaMenuModel* tail() const;

    int count() const;

    Q_INVOKABLE void push(AyatanaMenuModel* model, int menuIndex);
    Q_INVOKABLE AyatanaMenuModel* pop();

Q_SIGNALS:
    void headChanged(AyatanaMenuModel* head);
    void tailChanged(AyatanaMenuModel* tail);
    void countChanged(int count);

private Q_SLOTS:
    void onRemove();

private:
    QList<LomiriMenuModelEntry*> m_menuModels;
};

#endif // LOMIRIMENUMODELSTACK_H
