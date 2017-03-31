/*
 * Copyright (C) 2017 Canonical, Ltd.
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

#ifndef WINDOWMARGINS_H
#define WINDOWMARGINS_H

#include <QQuickItem>
#include <QRectF>

/*
 * Specifies window margins for different Mir window types
 *
 * Used to inform MirAL so that it can take window management decisions that match
 * the visuals drawn by Unity.
 */
class WindowMargins : public QQuickItem
{
    Q_OBJECT

    // Margins for windows of normal type
    Q_PROPERTY(QRectF normal READ normal WRITE setNormal NOTIFY normalChanged)

    // Margins for windows of dialog type
    Q_PROPERTY(QRectF dialog READ dialog WRITE setDialog NOTIFY dialogChanged)

    // TODO: Add margins for other window types as needed

public:
    QRectF normal() const;
    void setNormal(QRectF value);

    QRectF dialog() const;
    void setDialog(QRectF value);

protected:
    void itemChange(ItemChange change, const ItemChangeData &value) override;

Q_SIGNALS:
    void normalChanged();
    void dialogChanged();
private:
    QRectF m_normal;
    QRectF m_dialog;
};

#endif // WINDOWMARGINS_H
