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

#include <QQuickView>
#include <QDebug>
#include <QGuiApplication>
#include <QQuickView>
#include <QtQml/qqml.h>
#include <QStringListModel>
#include <QQmlContext>
#include <QQmlEngine>
#include <QGuiApplication>

#include "verticaljournal.h"

class DummyModel : public QAbstractListModel {
    Q_OBJECT
public:
    DummyModel() : m_count(0) {}

    int rowCount(const QModelIndex & /*parent*/) const override
    {
        return m_count;
    }

    QVariant data(const QModelIndex & /*index*/, int /*role*/) const override
    {
        return QVariant();
    }

    void setCount(int count)
    {
        beginResetModel();
        m_count = count;
        endResetModel();
    }

public slots:
    void addItem()
    {
        beginInsertRows(QModelIndex(), m_count, m_count);
        m_count++;
        endInsertRows();
    }

    void removeLast()
    {
        beginRemoveRows(QModelIndex(), m_count - 1, m_count - 1);
        m_count--;
        endRemoveRows();
    }

private:
    int m_count;
};

int main(int argc, char *argv[])
{
    QGuiApplication a(argc, argv);

    QQuickView *view = new QQuickView();
    view->setResizeMode(QQuickView::SizeRootObjectToView);

    DummyModel model;
    model.setCount(3);

    QStringListModel listModel;
    listModel.setStringList(QStringList() << QString());

    view->rootContext()->setContextProperty("listModel", &listModel);
    view->rootContext()->setContextProperty("gridModel", &model);

    view->setSource(QUrl::fromLocalFile(DASHVIEWSTEST_FOLDER "/organicgridtry.qml"));

    view->show();
    view->resize(530, 400);

    QObject::connect(view->rootObject(), SIGNAL(add()), &model, SLOT(addItem()));
    QObject::connect(view->rootObject(), SIGNAL(remove()), &model, SLOT(removeLast()));

    return a.exec();
}

#include "organicgridtry.moc"
