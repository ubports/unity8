/*
 * Copyright (C) 2013 Canonical, Ltd.
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

class QHeightModel : public QStringListModel {
    Q_OBJECT
public:
    QHash<int, QByteArray> roleNames() const override
    {
        QHash<int, QByteArray> roles;
        roles.insert(Qt::DisplayRole, "modelHeight");
        return roles;
    }

public slots:
    void add(int height)
    {
        if (height <= 0) {
            height = 50 + 50. * qrand() / RAND_MAX ;
        }
        QStringList sl = stringList();
        sl << QString::number(height);
        setStringList(sl);
    }

    void remove()
    {
        QStringList sl = stringList();
        if (!sl.isEmpty()) {
            sl.removeLast();
            setStringList(sl);
        }
    }
};

int main(int argc, char *argv[])
{
    QGuiApplication a(argc, argv);

    QQuickView *view = new QQuickView();
    view->setResizeMode(QQuickView::SizeRootObjectToView);

    QHeightModel model;
    QStringList heightList;
    heightList << "100" << "50" << "125";
    model.setStringList(heightList);

    QStringListModel listModel;
    listModel.setStringList(QStringList() << QString());

    view->rootContext()->setContextProperty("listModel", &listModel);
    view->rootContext()->setContextProperty("vjModel", &model);

    view->setSource(QUrl::fromLocalFile(DASHVIEWSTEST_FOLDER "/verticaljournaltry.qml"));

    view->show();
    view->resize(530, 400);

    QObject::connect(view->rootObject(), SIGNAL(add(int)), &model, SLOT(add(int)));
    QObject::connect(view->rootObject(), SIGNAL(remove()), &model, SLOT(remove()));

    return a.exec();
}

#include "verticaljournaltry.moc"
