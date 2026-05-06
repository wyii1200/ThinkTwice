import { createFileRoute, Link } from "@tanstack/react-router";
import { MobileFrame } from "@/components/MobileFrame";
import { PixelCat } from "@/components/PixelCat";
import { Settings, ChevronRight, Award, BarChart3, Wallet, Target, Moon, Sun } from "lucide-react";
import { useState } from "react";

export const Route = createFileRoute("/profile")({ component: Profile });

function Profile() {
  const [dark, setDark] = useState(true);
  return (
    <MobileFrame>
      <div className="px-5 pt-3 pb-6">
        <div className="flex justify-between items-center">
          <h1 className="text-2xl font-black">Profile</h1>
          <button className="w-10 h-10 rounded-full glass flex items-center justify-center"><Settings className="w-4 h-4" /></button>
        </div>

        <div className="mt-4 glass-strong rounded-3xl p-5 relative overflow-hidden">
          <div className="absolute inset-0 bg-grad-ai opacity-15" />
          <div className="relative flex items-center gap-4">
            <div className="bg-secondary/60 rounded-2xl p-2 border border-border">
              <PixelCat breed="orange-tabby" size={80} hat="crown" glasses />
            </div>
            <div>
              <div className="text-lg font-black">Aiman Hakim</div>
              <div className="text-xs text-muted-foreground">Universiti Malaya · Y3</div>
              <div className="font-pixel text-[10px] text-gold mt-2">LVL 4 · BUILDER</div>
            </div>
          </div>
          <div className="relative mt-4 grid grid-cols-3 gap-2">
            <Stat v="68" l="Resilience" />
            <Stat v="14🔥" l="Streak" />
            <Stat v="9" l="Badges" />
          </div>
        </div>

        <div className="mt-4 grid grid-cols-2 gap-3">
          <Tile to="/gxbank" icon={Wallet} label="GXBank Vaults" value="RM 457" tone="emerald" />
          <Tile to="/analytics" icon={BarChart3} label="Insights" value="12 reports" tone="ai" />
          <Tile to="/resilience" icon={Award} label="Resilience" value="Builder" tone="gold" />
          <Tile to="/squad" icon={Target} label="Goals" value="3 active" tone="ai" />
        </div>

        <div className="mt-4 text-xs font-semibold text-muted-foreground uppercase tracking-wider">Journey</div>
        <div className="mt-2 glass-strong rounded-3xl p-4 space-y-3">
          {[
            { d: "Jan 2026", t: "Joined ThinkTwice", e: "🎉" },
            { d: "Feb 2026", t: "First RM100 saved", e: "💰" },
            { d: "Mar 2026", t: "30-day streak unlocked", e: "🔥" },
            { d: "May 2026", t: "Reached 'Builder' rank", e: "🏗️" },
          ].map((j, i) => (
            <div key={i} className="flex items-center gap-3">
              <div className="text-2xl">{j.e}</div>
              <div className="flex-1">
                <div className="text-sm font-semibold">{j.t}</div>
                <div className="text-[11px] text-muted-foreground">{j.d}</div>
              </div>
            </div>
          ))}
        </div>

        <div className="mt-4 glass-strong rounded-3xl divide-y divide-border overflow-hidden">
          <Row icon={dark ? Moon : Sun} label={dark ? "Dark mode" : "Light mode"} right={
            <button onClick={() => setDark(!dark)} className={`w-11 h-6 rounded-full p-0.5 flex ${dark ? "bg-ai justify-end" : "bg-secondary"}`}><div className="w-5 h-5 rounded-full bg-white" /></button>
          } />
          <Row icon={Settings} label="Account & security" />
          <Row icon={Award} label="Achievements (9)" />
        </div>

        <button className="mt-4 w-full text-sm text-risk py-3">Sign out</button>
      </div>
    </MobileFrame>
  );
}

function Stat({ v, l }: { v: string; l: string }) {
  return <div className="rounded-2xl bg-white/10 backdrop-blur p-2 text-center"><div className="text-sm font-black">{v}</div><div className="text-[9px] text-muted-foreground uppercase tracking-wider">{l}</div></div>;
}

function Tile({ to, icon: Icon, label, value, tone }: any) {
  const c = tone === "emerald" ? "bg-grad-emerald" : tone === "gold" ? "bg-grad-gold" : "bg-grad-ai";
  return (
    <Link to={to} className="glass-strong rounded-3xl p-4 block">
      <div className={`w-10 h-10 rounded-xl ${c} flex items-center justify-center`}><Icon className="w-5 h-5 text-white" /></div>
      <div className="text-[11px] text-muted-foreground mt-2">{label}</div>
      <div className="text-sm font-bold">{value}</div>
    </Link>
  );
}

function Row({ icon: Icon, label, right }: any) {
  return (
    <div className="px-4 py-3 flex items-center gap-3">
      <Icon className="w-4 h-4 text-muted-foreground" />
      <div className="flex-1 text-sm font-medium">{label}</div>
      {right ?? <ChevronRight className="w-4 h-4 text-muted-foreground" />}
    </div>
  );
}
