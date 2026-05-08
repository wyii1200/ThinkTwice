import { Link, Outlet, useLocation } from "@tanstack/react-router";
import { Home, Map, Trophy, BarChart3, User } from "lucide-react";

const tabs = [
  { to: "/", icon: Home, label: "Home" },
  { to: "/radar", icon: Map, label: "Radar" },
  { to: "/challenges", icon: Trophy, label: "Quests" },
  { to: "/insights", icon: BarChart3, label: "Insights" },
  { to: "/profile", icon: User, label: "Profile" },
] as const;

export function MobileShell() {
  const loc = useLocation();
  const hideNav = ["/splash", "/login", "/onboarding"].some((p) =>
    loc.pathname.startsWith(p),
  );
  return (
    <div className="mx-auto flex min-h-screen max-w-md flex-col bg-background">
      <main className={`flex-1 ${hideNav ? "" : "pb-24"}`}>
        <Outlet />
      </main>
      {!hideNav && (
      <nav className="fixed bottom-0 left-1/2 z-50 w-full max-w-md -translate-x-1/2 border-t border-border/60 bg-card/95 px-2 pb-3 pt-2 backdrop-blur-lg">
        <div className="flex items-center justify-between">
          {tabs.map(({ to, icon: Icon, label }) => {
            const active = to === "/" ? loc.pathname === "/" : loc.pathname.startsWith(to);
            return (
              <Link
                key={to}
                to={to}
                className={`flex flex-1 flex-col items-center gap-1 rounded-xl py-1.5 text-[11px] font-medium transition-colors ${
                  active ? "text-primary" : "text-muted-foreground"
                }`}
              >
                <div
                  className={`flex h-9 w-9 items-center justify-center rounded-2xl transition-all ${
                    active ? "bg-primary/15 scale-110" : ""
                  }`}
                >
                  <Icon className="h-5 w-5" />
                </div>
                {label}
              </Link>
            );
          })}
        </div>
      </nav>
      )}
    </div>
  );
}
