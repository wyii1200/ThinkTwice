import { createFileRoute, Link } from "@tanstack/react-router";
import { MobileFrame } from "@/components/MobileFrame";
import { Coffee, ShoppingBag, Bus, Film, BookOpen, Search, Filter } from "lucide-react";
import { PieChart, Pie, Cell, ResponsiveContainer } from "recharts";

export const Route = createFileRoute("/transactions")({ component: Transactions });

const data = [
  { name: "Food", v: 220, c: "var(--ai)" },
  { name: "Shop", v: 140, c: "var(--gold)" },
  { name: "Transport", v: 88, c: "var(--emerald)" },
  { name: "Fun", v: 60, c: "var(--risk)" },
];

const txns = [
  { i: Coffee, n: "Starbucks", c: "Food & Beverage · Mid Valley", t: "10:32 PM", a: -12, risk: true },
  { i: Bus, n: "Grab", c: "Transport · USJ → KLCC", t: "9:14 PM", a: -18 },
  { i: ShoppingBag, n: "Shopee", c: "Shopping · Apparel", t: "6:02 PM", a: -39 },
  { i: Coffee, n: "Tealive", c: "F&B · Sunway Pyramid", t: "3:21 PM", a: -7.5 },
  { i: BookOpen, n: "Kinokuniya", c: "Books · KLCC", t: "1:48 PM", a: -45 },
  { i: Film, n: "Netflix", c: "Subscription", t: "9:00 AM", a: -19.9 },
  { i: Bus, n: "Touch n Go", c: "Reload", t: "8:11 AM", a: -30 },
];

function Transactions() {
  return (
    <MobileFrame>
      <div className="px-5 pt-3">
        <div className="flex items-center justify-between">
          <h1 className="text-2xl font-black">Activity</h1>
          <div className="flex gap-2">
            <button className="w-9 h-9 rounded-xl glass flex items-center justify-center"><Search className="w-4 h-4" /></button>
            <button className="w-9 h-9 rounded-xl glass flex items-center justify-center"><Filter className="w-4 h-4" /></button>
          </div>
        </div>

        {/* Breakdown */}
        <div className="mt-4 glass-strong rounded-3xl p-4 flex gap-4 items-center">
          <div className="w-28 h-28 relative">
            <ResponsiveContainer>
              <PieChart>
                <Pie data={data} dataKey="v" innerRadius={36} outerRadius={52} stroke="none">
                  {data.map((d, i) => <Cell key={i} fill={d.c} />)}
                </Pie>
              </PieChart>
            </ResponsiveContainer>
            <div className="absolute inset-0 flex flex-col items-center justify-center">
              <div className="text-[10px] text-muted-foreground">This week</div>
              <div className="text-lg font-black">RM508</div>
            </div>
          </div>
          <div className="flex-1 space-y-1.5">
            {data.map((d) => (
              <div key={d.name} className="flex items-center gap-2 text-xs">
                <span className="w-2 h-2 rounded-full" style={{ background: d.c }} />
                <span className="flex-1">{d.name}</span>
                <span className="font-semibold">RM{d.v}</span>
              </div>
            ))}
          </div>
        </div>

        {/* Tabs */}
        <div className="mt-4 flex gap-2">
          {["All", "Income", "Saves", "Risk"].map((t, i) => (
            <button key={t} className={`px-4 py-1.5 rounded-full text-xs font-semibold ${i === 0 ? "bg-grad-ai text-white" : "glass"}`}>{t}</button>
          ))}
        </div>

        {/* List */}
        <div className="mt-3 space-y-3 pb-6">
          {["Today", "Yesterday"].map((day, di) => (
            <div key={day}>
              <div className="text-[11px] font-semibold text-muted-foreground uppercase tracking-wider mb-1.5 px-1">{day}</div>
              <div className="glass-strong rounded-3xl divide-y divide-border overflow-hidden">
                {txns.slice(di*4, di*4+4).map((t, i) => (
                  <Link to="/nudge" key={i} className="px-4 py-3 flex items-center gap-3 animate-slide-up" style={{ animationDelay: `${i*40}ms` }}>
                    <div className={`w-10 h-10 rounded-xl flex items-center justify-center ${t.risk ? "bg-grad-risk" : "bg-secondary"}`}>
                      <t.i className="w-4 h-4 text-white" />
                    </div>
                    <div className="flex-1 min-w-0">
                      <div className="text-sm font-semibold truncate flex items-center gap-1.5">
                        {t.n} {t.risk && <span className="text-[9px] px-1.5 py-0.5 rounded-full bg-risk/20 text-risk uppercase tracking-wider">risk</span>}
                      </div>
                      <div className="text-[11px] text-muted-foreground truncate">{t.c} · {t.t}</div>
                    </div>
                    <div className="text-sm font-bold">{t.a > 0 ? "+" : "-"}RM{Math.abs(t.a).toFixed(2)}</div>
                  </Link>
                ))}
              </div>
            </div>
          ))}
        </div>
      </div>
    </MobileFrame>
  );
}
