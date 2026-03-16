import React from "react";
import { Separator } from "./ui/separator";
import { SidebarTrigger } from "./ui/sidebar";

export function SiteHeader({ title, actions }) {
  return (
    <header className="flex h-12 shrink-0 items-center gap-2 border-b">
      <div className="flex w-full items-center gap-1 px-4 lg:gap-2 lg:px-6">
        <SidebarTrigger className="-ml-1" />
        <Separator
          orientation="vertical"
          className="mx-2 data-[orientation=vertical]:h-4" />

        {title && <h1 className="text-base font-medium">{title}</h1>}
        {actions && <div className="ml-auto">{actions}</div>}
      </div>
    </header>);

}
