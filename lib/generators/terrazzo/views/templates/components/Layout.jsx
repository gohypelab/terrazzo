import React from "react";

import { getComponent } from "terrazzo";
import { AppSidebar as DefaultAppSidebar } from "./app-sidebar";
import { SiteHeader as DefaultSiteHeader } from "./site-header";
import { FlashMessages as DefaultFlashMessages } from "./FlashMessages";
import { SidebarProvider, SidebarInset } from "./ui";

export function Layout({ navigation, title, actions, children }) {
  const AppSidebar = getComponent("AppSidebar") || DefaultAppSidebar;
  const SiteHeader = getComponent("SiteHeader") || DefaultSiteHeader;
  const FlashMessages = getComponent("FlashMessages") || DefaultFlashMessages;

  return (
    <SidebarProvider>
      <AppSidebar variant="inset" navigation={navigation} />
      <SidebarInset>
        <SiteHeader title={title} actions={actions} />
        <div className="flex min-w-0 flex-1 flex-col">
          <div className="flex min-w-0 flex-1 flex-col gap-4 p-4 lg:p-6">
            <FlashMessages />
            {children}
          </div>
        </div>
      </SidebarInset>
    </SidebarProvider>);

}

export default Layout;
