"use client";

import { User, Shield, Activity, Server, Phone, PieChart, Users, BarChart3, Settings } from "lucide-react";
import { cn } from "@/lib/utils";
import { Tooltip, TooltipContent, TooltipProvider, TooltipTrigger } from "@/components/ui/tooltip";
import { useLocation } from "react-router";
import React from "react";

const navItems = [
  // Personal Account section
  { icon: User, href: "/portal", label: "Profile", description: "Manage your personal profile" },
  { icon: Shield, href: "/portal/security", label: "Security", description: "Security settings and authentication" },
  { icon: Activity, href: "/portal/sessions", label: "My Sessions", description: "View your active sessions" },

  // Admin section
  { icon: Server, href: "/portal/services", label: "My Services", description: "Manage your services" },
];

function NavItem({ item }: { item: (typeof navItems)[number] }) {
  const location = useLocation();
  console.log(location.pathname);
  const isActive = location.pathname === item.href;

  return (
    <Tooltip delayDuration={ 0 }>
      <TooltipTrigger asChild>
        <a
          href={ item.href }
          className={
 cn(
            "w-10 h-10 flex items-center justify-center rounded-lg transition-colors relative",
            isActive ? "bg-zinc-600 text-zinc-200" : "text-zinc-500 hover:text-zinc-200 hover:bg-zinc-900",
          )
}
          aria-label={ item.label }
        >
          <item.icon className="w-5 h-5" />
        </a>
      </TooltipTrigger>
      <TooltipContent side="right" className="flex flex-col gap-1 bg-zinc-800 after:bg-zinc-800 ">
        <p className="font-medium text-zinc-300">{item.label}</p>
        <p className="text-xs text-zinc-600">{item.description}</p>
      </TooltipContent>
    </Tooltip>
  );
}

export function Sidebar() {
  return (
    <TooltipProvider>
      <aside className="absolute left-0 top-13 z-10 bottom-24 w-16 py-4 flex flex-col border-r border-zinc-800">
        <div className="flex-1 flex flex-col items-center gap-4 py-4">
          {
navItems.map((item) => (
            <NavItem key={ item.href } item={ item } />
          ))
}
        </div>
      </aside>
    </TooltipProvider>
  );
}

