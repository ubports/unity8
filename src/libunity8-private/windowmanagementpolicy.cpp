#include "windowmanagementpolicy.h"

WindowManagementPolicy* WindowManagementPolicy::m_self = nullptr;

WindowManagementPolicy::WindowManagementPolicy(const miral::WindowManagerTools &tools, qtmir::WindowManagementPolicyPrivate &dd)
    : qtmir::WindowManagementPolicy(tools, dd)
{
    m_self = this;
}

WindowManagementPolicy *WindowManagementPolicy::instance()
{
    return m_self;
}

void WindowManagementPolicy::advise_new_window(miral::WindowInfo const& window_info)
{
    qtmir::WindowManagementPolicy::advise_new_window(window_info);

    auto const parent = window_info.parent();

    if (!parent)
        tools.add_tree_to_workspace(window_info.window(), m_activeWorkspace);
}

std::shared_ptr<miral::Workspace> WindowManagementPolicy::create_workspace()
{
    return tools.create_workspace();
}

void WindowManagementPolicy::setActiveWorkspace(const std::shared_ptr<miral::Workspace> &workspace)
{
    if (workspace == m_activeWorkspace)
        return;
    m_activeWorkspace = workspace;
}

