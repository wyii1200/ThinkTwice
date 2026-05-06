import { Link, useLocation } from "@tanstack/react-router";
import { Home, Activity, MapPin, Trophy, User, Sparkles } from "lucide-react";
import { type ReactNode } from "react";

const tabs = [
  { to: "/dashboard", icon: Home, label: "Home" },
  { to: "/transactions", icon: Activity, label: "Activity" },
  { to: "/radar", icon: MapPin, label: "Radar" },
  { to: "/gamify", icon: Trophy, label: "Quests" },
  { to: "/profile", icon: User, label: "Profile" },
] as const;

export function MobileFrame({ children, hideNav = false, hideStatus = false }: { children: ReactNode; hideNav?: boolean; hideStatus?: boolean }) {
  const loc = useLocation();
  return (
    <div className="min-h-screen w-full bg-app flex items-center justify-center p-0 sm:p-6">
      {/* Ambient blobs */}
      <div className="pointer-events-none fixed inset-0 overflow-hidden">
        <div className="absolute -top-40 -left-40 w-96 h-96 bg-grad-ai opacity-20 blur-3xl animate-blob" />
        <div className="absolute -bottom-40 -right-40 w-96 h-96 bg-grad-emerald opacity-15 blur-3xl animate-blob" style={{ animationDelay: "3s" }} />
      </div>

      <div className="relative w-full sm:w-[400px] sm:h-[860px] sm:rounded-[3rem] sm:border-[10px] sm:border-black sm:shadow-2xl bg-background overflow-hidden flex flex-col">
        {/* Notch */}
        <div className="hidden sm:block absolute top-0 left-1/2 -translate-x-1/2 w-32 h-7 bg-black rounded-b-3xl z-50" />
        {/* Status bar */}
        {!hideStatus && (
          <div className="flex items-center justify-between px-6 pt-3 pb-1 text-[11px] font-medium text-foreground/80 z-40">
            <span>9:41</span>
            <span className="flex items-center gap-1"><Sparkles className="w-3 h-3 text-ai" /> ThinkTwice</span>
            <span>100%</span>
          </div>
        )}

        <div className="flex-1 overflow-y-auto scrollbar-hide pb-24">
          {children}
        </div>

        {!hideNav && (
          <nav className="absolute bottom-0 inset-x-0 z-40 px-3 pb-3">
            <div className="glass-strong rounded-3xl px-2 py-2 flex items-center justify-between shadow-card">
              {tabs.map((t) => {
                const active = loc.pathname.startsWith(t.to);
                const Icon = t.icon;
                return (
                  <Link key={t.to} to={t.to} className="flex-1 flex flex-col items-center gap-0.5 py-1.5 rounded-2xl transition">
                    <div className={`p-1.5 rounded-xl transition ${active ? "bg-grad-ai glow-ai" : ""}`}>
                      <Icon className={`w-4 h-4 ${active ? "text-white" : "text-muted-foreground"}`} />
                    </div>
                    <span className={`text-[9px] font-medium ${active ? "text-foreground" : "text-muted-foreground"}`}>{t.label}</span>
                  </Link>
                );
              })}
            </div>
          </nav>
        )}
      </div>
    </div>
  );
}
