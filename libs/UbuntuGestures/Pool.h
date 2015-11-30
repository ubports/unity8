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

#ifndef UBUNTUGESTURES_POOL_H
#define UBUNTUGESTURES_POOL_H

#include <QVector>

#include "UbuntuGesturesGlobal.h"

/*
  An object pool.
  Avoids unnecessary creations/initializations and deletions/destructions of items. Useful
  in a scenario where items are created and destroyed very frequently but the total number
  of items at any given time remains small. They're stored in a unordered fashion.

  To be used in Pool, ItemType needs to have the following methods:

  - ItemType();

  A constructor that takes no parameters. An object contructed with it must return false if
  isValid() is called.

  - bool isValid() const;

  Returns wheter the object holds a valid , "filled" state or is empty.
  Used by Pool to check if the slot occupied by this object is actually available.

  - void reset();

  Resets the object to its initial, empty, state. After calling this method, isValid() must
  return false.
 */
template <class ItemType> class Pool
{
public:
    Pool() : m_lastUsedIndex(-1) {
    }

    class Iterator {
    public:
        Iterator() : index(-1), item(nullptr) {}
        Iterator(int index, ItemType *item)
            : index(index), item(item) {}

        ItemType *operator->() const { return item; }
        ItemType &operator*() const { return *item; }
        ItemType &value() const { return *item; }

        operator bool() const { return item != nullptr; }

        int index;
        ItemType *item;
    };

    ItemType &getEmptySlot() {
        Q_ASSERT(m_lastUsedIndex < m_slots.size());

        // Look for an in-between vacancy first
        for (int i = 0; i < m_lastUsedIndex; ++i) {
            ItemType &item = m_slots[i];
            if (!item.isValid()) {
                return item;
            }
        }

        ++m_lastUsedIndex;
        if (m_lastUsedIndex >= m_slots.size()) {
            m_slots.resize(m_lastUsedIndex + 1);
        }

        return m_slots[m_lastUsedIndex];
    }

    void freeSlot(Iterator &iterator) {
        m_slots[iterator.index].reset();
        if (iterator.index == m_lastUsedIndex) {
            do {
                --m_lastUsedIndex;
            } while (m_lastUsedIndex >= 0 && !m_slots.at(m_lastUsedIndex).isValid());
        }
    }

    // Iterates through all valid items (i.e. the occupied slots)
    // calling the given function, with the option of ending the loop early.
    //
    // bool Func(Iterator& item)
    //
    // Returning true means it wants to continue the "for" loop, false
    // terminates the loop.
    template<typename Func> void forEach(Func func) {
        Iterator it;
        for (it.index = 0; it.index <= m_lastUsedIndex; ++it.index) {
            it.item = &m_slots[it.index];
            if (!it.item->isValid())
                continue;

            if (!func(it))
                break;
        }
    }

    bool isEmpty() const { return m_lastUsedIndex == -1; }


private:
    QVector<ItemType> m_slots;
    int m_lastUsedIndex;
};

#endif // UBUNTUGESTURES_POOL_H
