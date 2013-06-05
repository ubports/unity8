/*
 * Copyright (C) 2012, 2013 Canonical, Ltd.
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

#ifndef HUDCLIENT_H
#define HUDCLIENT_H

#include <QObject>

#include <hud-client.h>

class DeeListModel;
class QAbstractItemModel;

class HudClient : public QObject
{
    Q_OBJECT
    Q_PROPERTY(DeeListModel* results READ results)
    Q_PROPERTY(QAbstractItemModel* toolBarModel READ toolBarModel)

public:
    HudClient();
    ~HudClient();

    DeeListModel *results() const;

    QAbstractItemModel *toolBarModel() const;

    Q_INVOKABLE void executeCommand(int index);
    Q_INVOKABLE void setQuery(const QString &new_query);
    Q_INVOKABLE void startVoiceQuery();
    Q_INVOKABLE void executeParametrizedAction(const QVariant &values);
    Q_INVOKABLE void updateParametrizedAction(const QVariant &values);
    Q_INVOKABLE void cancelParametrizedAction();
    Q_INVOKABLE void executeToolBarAction(HudClientQueryToolbarItems action);

    void modelReady(bool needDisconnect);
    void modelReallyReady(bool needDisconnect);
    void queryModelsChanged();

Q_SIGNALS:
    void voiceQueryLoading();
    void voiceQueryListening();
    void voiceQueryHeardSomething();
    void voiceQueryFailed();
    void voiceQueryFinished(const QString &query);
    void commandExecuted();
    void showParametrizedAction(const QString &action, const QVariant &items);

private:
    HudClientQuery *m_clientQuery;
    DeeListModel *m_results;
    QAbstractItemModel *m_toolBarModel;
    int m_currentActionIndex;
    HudClientParam *m_currentActionParam;
};
Q_DECLARE_METATYPE(HudClientQueryToolbarItems)

#endif
