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

#include "lomirimenumodelstack.h"

#include <QDebug>
#include <lomirimenumodel.h>

class LomiriMenuModelEntry : public QObject {
    Q_OBJECT
public:
    LomiriMenuModelEntry(LomiriMenuModel* model, LomiriMenuModel* parentModel, int index)
    : m_model(model),
      m_parentModel(parentModel),
      m_index(index)
    {
        if (m_parentModel) {
            QObject::connect(m_parentModel, &LomiriMenuModel::rowsInserted, this, &LomiriMenuModelEntry::onRowsInserted);
            QObject::connect(m_parentModel, &LomiriMenuModel::rowsRemoved, this, &LomiriMenuModelEntry::onRowsRemoved);
            QObject::connect(m_parentModel, &LomiriMenuModel::modelReset, this, &LomiriMenuModelEntry::onModelReset);
        }
    }

    LomiriMenuModel* model() const { return m_model; }

private Q_SLOTS:
    void onRowsInserted(const QModelIndex&, int start, int end)
    {
        int delta = end-start + 1;
        if (start <= m_index) {
            m_index += delta;
        }
    }

    void onRowsRemoved(const QModelIndex&, int start, int end)
    {
        int delta = end-start + 1;
        if (start <= m_index) {
            if (start + delta > m_index) {
                // in the range removed
                Q_EMIT remove();
                disconnect(m_parentModel, 0, this, 0);
            } else {
                m_index -= delta;
            }
        }
    }

    void onModelReset()
    {
        Q_EMIT remove();
        disconnect(m_parentModel, 0, this, 0);
    }

Q_SIGNALS:
    void remove();

private:
    LomiriMenuModel* m_model;
    LomiriMenuModel* m_parentModel;
    int m_index;
};

LomiriMenuModelStack::LomiriMenuModelStack(QObject* parent)
    : QObject(parent)
{
}

LomiriMenuModelStack::~LomiriMenuModelStack()
{
    qDeleteAll(m_menuModels);
    m_menuModels.clear();
}

LomiriMenuModel* LomiriMenuModelStack::head() const
{
    return !m_menuModels.isEmpty() ? m_menuModels.first()->model() : nullptr;
}

void LomiriMenuModelStack::setHead(LomiriMenuModel* model)
{
    if (head() != model) {
        qDeleteAll(m_menuModels);
        m_menuModels.clear();

        push(model, 0);
        Q_EMIT headChanged(model);
    }
}

LomiriMenuModel* LomiriMenuModelStack::tail() const
{
    return !m_menuModels.isEmpty() ? m_menuModels.last()->model() : nullptr;
}

int LomiriMenuModelStack::count() const
{
    return m_menuModels.count();
}

void LomiriMenuModelStack::push(LomiriMenuModel* model, int index)
{
    LomiriMenuModelEntry* entry = new LomiriMenuModelEntry(model, tail(), index);
    QObject::connect(entry, &LomiriMenuModelEntry::remove, this, &LomiriMenuModelStack::onRemove);

    m_menuModels << entry;
    Q_EMIT tailChanged(model);
    Q_EMIT countChanged(m_menuModels.count());
}

LomiriMenuModel* LomiriMenuModelStack::pop()
{
    if (m_menuModels.isEmpty()) {
        return nullptr;
    }
    LomiriMenuModelEntry* entry = m_menuModels.takeLast();
    LomiriMenuModel* model = entry->model();
    entry->deleteLater();

    Q_EMIT tailChanged(tail());
    if (m_menuModels.isEmpty()) {
        Q_EMIT headChanged(nullptr);
    }
    Q_EMIT countChanged(m_menuModels.count());

    return model;
}

void LomiriMenuModelStack::onRemove()
{
    LomiriMenuModelEntry* removed = qobject_cast<LomiriMenuModelEntry*>(sender());
    if (!m_menuModels.contains(removed))
        return;

    for (int i = m_menuModels.count() -1; i >= 0; i--) {
        LomiriMenuModelEntry* entry = m_menuModels[i];
        pop();
        if (entry == removed) {
            break;
        }
    }
}

#include "lomirimenumodelstack.moc"
