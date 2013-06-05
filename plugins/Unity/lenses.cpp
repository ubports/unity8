/*
 * Copyright (C) 2011 Canonical, Ltd.
 *
 * Authors:
 *  Florian Boucault <florian.boucault@canonical.com>
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

// Self
#include "lenses.h"

// Local
#include "lens.h"

// Qt
#include <QDebug>
#include <QtCore/QStringList>
#include <QtGui/QKeySequence>

// libunity-core
#include <UnityCore/FilesystemLenses.h>
#include <UnityCore/HomeLens.h>

Lenses::Lenses(QObject *parent)
    : QAbstractListModel(parent)
    , m_unityLenses(std::make_shared<unity::dash::FilesystemLenses>())
    , m_homeLens(std::make_shared<unity::dash::HomeLens>(QString::fromUtf8(dgettext("unity", "Home")).toStdString(),
                                                         QString::fromUtf8(dgettext("unity", "Home screen")).toStdString(),
                                                         QString::fromUtf8(dgettext("unity", "Search")).toStdString()))
    , m_loaded(false)
{
    m_roles[Lenses::RoleLens] = "lens";
    m_roles[Lenses::RoleId] = "id";
    m_roles[Lenses::RoleVisible] = "visible";

    m_homeLens->AddLenses(m_unityLenses);
    std::dynamic_pointer_cast<unity::dash::FilesystemLenses>(m_unityLenses)->lenses_loaded.connect(sigc::mem_fun(this, &Lenses::onLensesLoaded));
}

QHash<int, QByteArray> Lenses::roleNames() const
{
    return m_roles;
}

int Lenses::rowCount(const QModelIndex& parent) const
{
    Q_UNUSED(parent)

    return m_lenses.count();
}

QVariant Lenses::data(const QModelIndex& index, int role) const
{
    Q_UNUSED(role)

    if (!index.isValid()) {
        return QVariant();
    }

    Lens* lens = m_lenses.at(index.row());

    if (role == Lenses::RoleLens) {
        return QVariant::fromValue(lens);
    } else if (role == Lenses::RoleId) {
        return QVariant::fromValue(lens->id());
    } else if (role == Lenses::RoleVisible) {
        return QVariant::fromValue(lens->visible());
    } else {
        return QVariant();
    }
}

QVariant Lenses::get(int row) const
{
    return data(QAbstractListModel::index(row), 0);
}

QVariant Lenses::get(const QString& lens_id) const
{
    Q_FOREACH(Lens* lens, m_lenses) {
        if (lens->id() == lens_id) {
            return QVariant::fromValue(lens);
        }
    }

    return QVariant();
}

bool Lenses::loaded() const
{
    return m_loaded;
}

void Lenses::onLensAdded(const unity::dash::Lens::Ptr& lens)
{
    int index = m_lenses.count();
    beginInsertRows(QModelIndex(), index, index);
    addUnityLens(lens);
    endInsertRows();
}

void Lenses::onLensesLoaded()
{
    /* FIXME: this is temporary code that is required on mobile to order
       the lenses according to the design.
    */
    QStringList staticLenses;
    staticLenses << "mockmusic.lens" << "people.lens" << "home.lens" << "applications.lens" << "mockvideos.lens";

    // not all the lenses are guaranteed to go into the model (only if their UnitCore counterparts exist);
    // so build up a list of the valid ones, then add them later.
    QList<unity::dash::Lens::Ptr> added_lenses;

    // add statically ordered lenses
    Q_FOREACH(QString lensId, staticLenses) {
        if (lensId == "home.lens") {
            added_lenses << m_homeLens;
        } else {
            unity::dash::Lens::Ptr lens = m_unityLenses->GetLens(lensId.toStdString());
            if (lens != NULL) {
                added_lenses << lens;
            }
        }
    }

    // add remaining lenses
    unity::dash::Lenses::LensList lensesList = m_unityLenses->GetLenses();
    for(auto it = lensesList.begin(); it != lensesList.end(); ++it) {
        unity::dash::Lens::Ptr lens = (*it);
        if (!staticLenses.contains(QString::fromStdString(lens->id))) {
            added_lenses << lens;
        }
    }

    if (added_lenses.count() > 0) {
        int index = rowCount();
        beginInsertRows(QModelIndex(), index, index+added_lenses.count()-1);
        Q_FOREACH(unity::dash::Lens::Ptr lens, added_lenses) {
            addUnityLens(lens);
        }
        endInsertRows();
    }

    m_loaded = true;
    Q_EMIT loadedChanged(m_loaded);

    // listen to dynamically added lenses
    m_homeLens->lens_added.connect(sigc::mem_fun(this, &Lenses::onLensAdded));
}

void Lenses::onLensPropertyChanged()
{
    QModelIndex lensIndex = index(m_lenses.indexOf(qobject_cast<Lens*>(sender())));
    Q_EMIT dataChanged(lensIndex, lensIndex);
}

void Lenses::addUnityLens(const unity::dash::Lens::Ptr& unity_lens)
{
    Lens* lens = new Lens(this);
    lens->setUnityLens(unity_lens);
    /* DOCME */
    QObject::connect(lens, SIGNAL(visibleChanged(bool)), this, SLOT(onLensPropertyChanged()));
    m_lenses.append(lens);
}

void Lenses::removeUnityLens(int index)
{
    Lens* lens = m_lenses.takeAt(index);

    delete lens;
}
