import { createFileRoute, Link } from "@tanstack/react-router";
import { MobileFrame } from "@/components/MobileFrame";
import { PixelCat } from "@/components/PixelCat";
import { Bell, Plus, Radar, Brain, Users, TrendingUp, Coffee, ShoppingBag, Bus, Sparkles, Flame, Shield } from "lucide-react";
import { Area, AreaChart, ResponsiveContainer } from "recharts";

export const Route = createFileRoute("/dashboard")({ component: Dashboard });

const sparkData = Array.from({ length: 14 }).map((_, i) => ({ v: 40 + Math.sin(i / 2) * 8 + i * 1.6 }));

function Dashboard() {
  return (
    <MobileFrame>
      <div className="px-5 pb-6">
        {/* Header */}
        <div className="flex items-center justify-between pt-3">
          <div>
            <div className="text-xs text-muted-foreground">Good evening, Aiman</div>
            <div className="text-lg font-bold flex items-center gap-1.5">Mochi is watching <Sparkles className="w-4 h-4 text-ai" /></div>
          </div>
          <button className="relative w-10 h-10 rounded-full glass flex items-center justify-center">
            <Bell className="w-4 h-4" />
            <span className="absolute top-1.5 right-1.5 w-2 h-2 rounded-full bg-risk" />
          </button>
        </div>

        {/* Hero balance card */}
        <div className="mt-5 relative rounded-3xl p-5 bg-grad-ai overflow-hidden glow-ai">
          <div className="absolute -top-10 -right-10 w-40 h-40 bg-white/20 rounded-full blur-2xl" />
          <div className="flex justify-between items-start relative">
            <div>
              <div className="text-xs text-white/80 font-medium">Available · GXBank</div>
              <div className="text-3xl font-black text-white mt-1">RM 1,847.<span className="text-xl">22</span></div>
              <div className="text-[11px] text-white/70 mt-1">+RM 124 saved this month</div>
            </div>
            <div className="text-right">
              <div className="text-[10px] text-white/70 uppercase tracking-wider">Resilience</div>
              <Link to="/resilience" className="block">
                <div className="text-2xl font-black text-white">68</div>
                <div className="text-[10px] text-emerald flex items-center gap-0.5 justify-end"><TrendingUp className="w-3 h-3" /> +6</div>
              </Link>
            </div>
          </div>

          <div className="mt-4 grid grid-cols-3 gap-2 relative">
            <MiniStat label="Vault" value="RM 312" />
            <MiniStat label="Streak" value="14🔥" />
            <MiniStat label="Daily" value="RM 28/45" />
          </div>
        </div>

        {/* Pixel cat companion */}
        <div className="mt-4 glass-strong rounded-3xl p-4 flex items-center gap-4 relative overflow-hidden">
          <div className="absolute right-0 top-0 w-32 h-32 bg-grad-gold opacity-10 blur-2xl" />
          <PixelCat breed="orange-tabby" size={68} hat="cap" glasses />
          <div className="flex-1 relative">
            <div className="font-bold text-sm">Mochi · Lvl 4</div>
            <div className="text-[11px] text-muted-foreground">"You saved RM10 by skipping kopi today. Proud!"</div>
            <div className="mt-2 h-1.5 bg-secondary rounded-full overflow-hidden">
              <div className="h-full bg-grad-gold" style={{ width: "62%" }} />
            </div>
            <div className="text-[10px] text-muted-foreground mt-0.5">620 / 1000 XP to Lvl 5</div>
          </div>
        </div>

        {/* AI insight cards */}
        <div className="mt-5 flex justify-between items-center">
          <div className="text-sm font-bold flex items-center gap-1.5"><Brain className="w-4 h-4 text-ai" /> AI insights</div>
          <span className="text-[10px] text-muted-foreground">Updated 2 min ago</span>
        </div>

        <div className="mt-2 flex gap-3 overflow-x-auto scrollbar-hide -mx-5 px-5 pb-1">
          <InsightCard tone="emerald" title="You avoided RM120 overspending this month." sub="Mostly skipped late-night Grab orders." chart="up" />
          <InsightCard tone="ai" title="Food spending down 18% this week." sub="Keep this rhythm to unlock 'Cafe Hermit' badge." chart="down" />
          <InsightCard tone="risk" title="Subscription leak detected." sub="Spotify Duo · unused for 23 days. RM14.90/mo." />
        </div>

        {/* Quick actions */}
        <div className="mt-5 grid grid-cols-4 gap-2">
          <Quick to="/dashboard" icon={Plus} label="Save Now" tone="emerald" />
          <Quick to="/radar" icon={Radar} label="Smart Radar" tone="ai" />
          <Quick to="/coach" icon={Brain} label="AI Coach" tone="purple" />
          <Quick to="/squad" icon={Users} label="Squad" tone="gold" />
        </div>

        {/* Recent activity */}
        <div className="mt-5">
          <div className="flex justify-between items-center mb-2">
            <div className="text-sm font-bold">Live transactions</div>
            <Link to="/transactions" className="text-xs text-ai">See all</Link>
          </div>
          <div className="glass-strong rounded-3xl divide-y divide-border overflow-hidden">
            <Tx icon={Coffee} name="Starbucks" cat="Food · Mid Valley" time="10:32 PM" amt={-12} risk />
            <Tx icon={Bus} name="Grab" cat="Transport · USJ→KL" time="9:14 PM" amt={-18} />
            <Tx icon={ShoppingBag} name="Shopee" cat="Shopping · Apparel" time="6:02 PM" amt={-39} />
            <Tx icon={Shield} name="Auto-save Vault" cat="Round-up · 12 tx" time="5:00 PM" amt={+8.4} save />
          </div>
        </div>

        {/* AI floating button */}
        <Link to="/coach" className="fixed sm:absolute right-5 bottom-24 z-30">
          <div className="relative">
            <div className="absolute inset-0 bg-grad-ai rounded-full animate-pulse-ring" />
            <div className="relative w-14 h-14 rounded-full bg-grad-ai glow-ai flex items-center justify-center shadow-card">
              <Brain className="w-6 h-6 text-white" />
            </div>
          </div>
        </Link>
      </div>
    </MobileFrame>
  );
}

function MiniStat({ label, value }: { label: string; value: string }) {
  return (
    <div className="rounded-2xl bg-white/15 backdrop-blur p-2">
      <div className="text-[10px] text-white/70 uppercase tracking-wider">{label}</div>
      <div className="text-sm font-bold text-white">{value}</div>
    </div>
  );
}

function InsightCard({ tone, title, sub, chart }: { tone: "emerald" | "ai" | "risk"; title: string; sub: string; chart?: "up" | "down" }) {
  const grad = tone === "emerald" ? "bg-grad-emerald" : tone === "ai" ? "bg-grad-ai" : "bg-grad-risk";
  return (
    <div className={`shrink-0 w-[260px] rounded-3xl p-4 ${grad} relative overflow-hidden text-white`}>
      <div className="absolute -bottom-6 -right-6 w-32 h-20 opacity-30">
        <ResponsiveContainer width="100%" height="100%">
          <AreaChart data={sparkData}><Area dataKey="v" stroke="#fff" fill="#fff" fillOpacity={0.3} strokeWidth={2} /></AreaChart>
        </ResponsiveContainer>
      </div>
      <div className="relative">
        <div className="text-sm font-bold leading-snug">{title}</div>
        <div className="text-[11px] mt-1 text-white/80">{sub}</div>
      </div>
    </div>
  );
}

function Quick({ to, icon: Icon, label, tone }: any) {
  const grad = { emerald: "bg-grad-emerald", ai: "bg-grad-ai", purple: "bg-grad-ai", gold: "bg-grad-gold" }[tone as string] ?? "bg-grad-ai";
  return (
    <Link to={to} className="glass-strong rounded-2xl p-2.5 flex flex-col items-center gap-1.5">
      <div className={`w-10 h-10 rounded-xl ${grad} flex items-center justify-center`}><Icon className="w-5 h-5 text-white" /></div>
      <span className="text-[10px] font-semibold">{label}</span>
    </Link>
  );
}

function Tx({ icon: Icon, name, cat, time, amt, risk, save }: any) {
  return (
    <div className="px-4 py-3 flex items-center gap-3">
      <div className={`w-10 h-10 rounded-xl flex items-center justify-center ${save ? "bg-grad-emerald" : risk ? "bg-grad-risk" : "bg-secondary"}`}>
        <Icon className="w-4 h-4 text-white" />
      </div>
      <div className="flex-1 min-w-0">
        <div className="text-sm font-semibold truncate">{name}</div>
        <div className="text-[11px] text-muted-foreground truncate">{cat} · {time}</div>
      </div>
      <div className={`text-sm font-bold ${amt > 0 ? "text-emerald" : risk ? "text-risk" : "text-foreground"}`}>{amt > 0 ? "+" : ""}RM{Math.abs(amt).toFixed(2)}</div>
    </div>
  );
}
