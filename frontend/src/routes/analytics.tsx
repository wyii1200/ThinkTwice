import { createFileRoute, Link } from "@tanstack/react-router";
import { MobileFrame } from "@/components/MobileFrame";
import { Bar, BarChart, Cell, ResponsiveContainer, XAxis, YAxis } from "recharts";
import { Brain, TrendingDown, TrendingUp } from "lucide-react";

export const Route = createFileRoute("/analytics")({ component: Analytics });

const months = ["Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"];
const data = months.map((m, i) => ({ m, save: 50 + Math.sin(i)*40 + i*8, spend: 800 + Math.cos(i)*60 }));

function Analytics() {
  return (
    <MobileFrame>
      <div className="px-5 pt-3 pb-6">
        <Link to="/profile" className="text-xs text-muted-foreground">← Back</Link>
        <h1 className="mt-2 text-2xl font-black">Insights</h1>

        <div className="mt-4 grid grid-cols-2 gap-3">
          <Card label="Saved YTD" value="RM 1,240" delta="+22%" tone="emerald" />
          <Card label="Spent YTD" value="RM 9,847" delta="-8%" tone="ai" />
        </div>

        <div className="mt-4 glass-strong rounded-3xl p-4">
          <div className="flex justify-between items-center">
            <div className="text-sm font-bold">Savings growth</div>
            <span className="text-[10px] text-muted-foreground">12 months</span>
          </div>
          <div className="h-40 mt-2">
            <ResponsiveContainer>
              <BarChart data={data}>
                <XAxis dataKey="m" stroke="oklch(0.7 0.02 260)" fontSize={9} axisLine={false} tickLine={false} />
                <YAxis hide />
                <Bar dataKey="save" radius={[6,6,0,0]}>
                  {data.map((_, i) => <Cell key={i} fill={i === 11 ? "oklch(0.74 0.18 155)" : "oklch(0.3 0.05 265)"} />)}
                </Bar>
              </BarChart>
            </ResponsiveContainer>
          </div>
        </div>

        {/* AI personality */}
        <div className="mt-4 rounded-3xl p-5 bg-grad-ai relative overflow-hidden text-white">
          <div className="absolute -bottom-8 -right-8 w-40 h-40 bg-white/20 rounded-full blur-2xl" />
          <div className="relative">
            <div className="flex items-center gap-2 text-xs uppercase tracking-wider opacity-80"><Brain className="w-3.5 h-3.5" /> Your money personality</div>
            <div className="text-2xl font-black mt-2">The Mindful Strategist 🧘</div>
            <div className="text-xs opacity-90 mt-2 leading-relaxed">You spend with intent on coffee and books, but auto-save aggressively. You're 73% more disciplined than peers in your income bracket.</div>
            <div className="mt-3 grid grid-cols-3 gap-2">
              {[
                { l: "Discipline", v: 86 },
                { l: "Frugality", v: 64 },
                { l: "Resilience", v: 72 },
              ].map(t => (
                <div key={t.l} className="rounded-2xl bg-white/15 p-2">
                  <div className="text-[10px] opacity-80">{t.l}</div>
                  <div className="text-lg font-black">{t.v}</div>
                </div>
              ))}
            </div>
          </div>
        </div>

        <div className="mt-4 glass-strong rounded-3xl p-4">
          <div className="text-sm font-bold mb-3">Smart decision score</div>
          <div className="space-y-2">
            {[
              { k: "Skipped impulse buys", v: 14, m: 18 },
              { k: "Took cheaper alternative", v: 9, m: 12 },
              { k: "Auto-saved instead of spent", v: 22, m: 22 },
            ].map(r => (
              <div key={r.k}>
                <div className="flex justify-between text-xs"><span>{r.k}</span><span className="font-semibold">{r.v}/{r.m}</span></div>
                <div className="h-1.5 bg-secondary rounded-full overflow-hidden mt-1"><div className="h-full bg-grad-emerald" style={{ width: `${(r.v/r.m)*100}%` }} /></div>
              </div>
            ))}
          </div>
        </div>

        <div className="mt-4 glass rounded-2xl p-4 flex items-center gap-3">
          <div className="text-3xl">📊</div>
          <div className="flex-1">
            <div className="text-sm font-bold">Weekly report ready</div>
            <div className="text-[11px] text-muted-foreground">12 insights · 3 wins · 1 risk</div>
          </div>
          <button className="px-3 py-2 rounded-xl bg-grad-ai text-white text-xs font-bold">View</button>
        </div>
      </div>
    </MobileFrame>
  );
}

function Card({ label, value, delta, tone }: { label: string; value: string; delta: string; tone: "emerald" | "ai" }) {
  const up = delta.startsWith("+");
  return (
    <div className="glass-strong rounded-3xl p-4">
      <div className="text-[10px] text-muted-foreground uppercase tracking-wider">{label}</div>
      <div className="text-xl font-black mt-1">{value}</div>
      <div className={`text-[11px] mt-1 flex items-center gap-1 ${tone === "emerald" ? "text-emerald" : "text-ai"}`}>
        {up ? <TrendingUp className="w-3 h-3" /> : <TrendingDown className="w-3 h-3" />} {delta} vs last year
      </div>
    </div>
  );
}
