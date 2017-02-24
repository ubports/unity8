#ifndef UNITY_WINDOWMANAGEMENTPOLICY_H
#define UNITY_WINDOWMANAGEMENTPOLICY_H

#include <QObject>
#include <qtmir/windowmanagementpolicy.h>

class Q_DECL_EXPORT WindowManagementPolicy : public QObject,
                                             public qtmir::WindowManagementPolicy
{
    Q_OBJECT
public:
    WindowManagementPolicy(const miral::WindowManagerTools &tools, qtmir::WindowManagementPolicyPrivate& dd);

    static WindowManagementPolicy *instance();

    void advise_new_window(miral::WindowInfo const& window_info) override;


    std::shared_ptr<miral::Workspace> create_workspace();

public Q_SLOTS:
    void setActiveWorkspace(const std::shared_ptr<miral::Workspace>& workspace);

private:
    static WindowManagementPolicy* m_self;
    std::shared_ptr<miral::Workspace> m_activeWorkspace;
};

#endif // UNITY_WINDOWMANAGEMENTPOLICY_H
