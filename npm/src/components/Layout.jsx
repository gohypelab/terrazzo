import React from "react";

import { AppSidebar } from "./app-sidebar";
import { SiteHeader } from "./site-header";
import { FlashMessages } from "./FlashMessages";
import { SidebarProvider, SidebarInset } from "terrazzo/ui";

export function Layout({ navigation, title, actions, children }) {
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
