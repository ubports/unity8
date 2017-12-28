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
 *
 * Authors: Nick Dedekind <nick.dedekind@canonical.com>
 */

#ifndef MOCK_UNITYMENUMODEL_H
#define MOCK_UNITYMENUMODEL_H

#include <QAbstractListModel>
class QQmlComponent;
class UnityMenuAction;
class ActionStateParser;

class Q_DECL_EXPORT UnityMenuModel : public QAbstractListModel
{
    Q_OBJECT
    Q_PROPERTY(QByteArray busName READ busName WRITE setBusName NOTIFY busNameChanged)
    Q_PROPERTY(QVariantMap actions READ actions WRITE setActions NOTIFY actionsChanged)
    Q_PROPERTY(QByteArray menuObjectPath READ menuObjectPath WRITE setMenuObjectPath NOTIFY menuObjectPathChanged)
    Q_PROPERTY(ActionStateParser* actionStateParser READ actionStateParser WRITE setActionStateParser NOTIFY actionStateParserChanged)
    Q_PROPERTY(QString nameOwner READ nameOwner NOTIFY nameOwnerChanged)

    // internal mock properties
    Q_PROPERTY(QVariant modelData READ modelData WRITE setModelData NOTIFY modelDataChanged)

public:
    UnityMenuModel(QObject *parent = nullptr);
    virtual ~UnityMenuModel();

    Q_INVOKABLE void insertRow(int row, const QVariant& data);
    Q_INVOKABLE void appendRow(const QVariant& data);
    Q_INVOKABLE void removeRow(int row);

    QVariant modelData() const;
    void setModelData(const QVariant& data);

    QByteArray busName() const;
    void setBusName(const QByteArray &busName);

    QVariantMap actions() const;
    void setActions(const QVariantMap &actions);

    QByteArray menuObjectPath() const;
    void setMenuObjectPath(const QByteArray &path);

    ActionStateParser* actionStateParser() const;
    void setActionStateParser(ActionStateParser* actionStateParser);

    QString nameOwner() const;

    Q_INVOKABLE int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    int columnCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;
    QModelIndex index(int row, int column = 0, const QModelIndex &parent = QModelIndex()) const override;
    QModelIndex parent(const QModelIndex &index) const override;
    QHash<int, QByteArray> roleNames() const override;

    Q_INVOKABLE QObject * submenu(int position, QQmlComponent* actionStateParser = nullptr);
    Q_INVOKABLE bool loadExtendedAttributes(int position, const QVariantMap &schema);
    Q_INVOKABLE QVariant get(int row, const QByteArray &role);

    Q_INVOKABLE void activate(int index, const QVariant& parameter = QVariant());
    Q_INVOKABLE void aboutToShow(int index);
    Q_INVOKABLE void changeState(int index, const QVariant& parameter);

    void registerAction(UnityMenuAction* action);
    void unregisterAction(UnityMenuAction* action);

Q_SIGNALS:
    void busNameChanged();
    void actionsChanged();
    void menuObjectPathChanged();
    void actionStateParserChanged();
    void nameOwnerChanged();

    // Internal mock usage
    void modelDataChanged();
    void aboutToShowCalled(int index);

    void activated(const QString& action);

private:
    QVariantMap rowData(int row) const;
    QVariant subMenuData(int row) const;

    class Row;
    QVariantList m_modelData;
    QList<UnityMenuModel*> submenus;

    QByteArray m_busName;
    QVariantMap m_actions;
    QByteArray m_menuObjectPath;

    enum RowCountStatus {
        NoRequestMade,
        TimerRunning,
        TimerFinished
    };
    RowCountStatus m_rowCountStatus;
};

#endif // MOCK_UNITYMENUMODEL_H
