import { createFileRoute, Link } from "@tanstack/react-router";
import { MobileFrame } from "@/components/MobileFrame";
import { TrendingUp, Shield, Flame, Radar } from "lucide-react";
import { Line, LineChart, ResponsiveContainer, XAxis, YAxis, Tooltip } from "recharts";

export const Route = createFileRoute("/resilience")({ component: Resilience });

const history = [50, 53, 51, 55, 58, 56, 60, 62, 61, 64, 66, 68].map((v, i) => ({ d: i + 1, v }));

function Resilience() {
  const score = 68;
  const dash = 2 * Math.PI * 80;
  const offset = dash * (1 - score / 100);

  return (
    <MobileFrame>
      <div className="px-5 pt-3 pb-6">
        <Link to="/dashboard" className="text-xs text-muted-foreground">← Back</Link>
        <h1 className="mt-2 text-2xl font-black">Resilience Score</h1>

        <div className="mt-4 glass-strong rounded-3xl p-6 flex flex-col items-center">
          <div className="relative w-48 h-48">
            <svg className="w-full h-full -rotate-90" viewBox="0 0 200 200">
              <circle cx="100" cy="100" r="80" stroke="oklch(0.3 0.04 265)" strokeWidth="14" fill="none" />
              <circle cx="100" cy="100" r="80" stroke="url(#sg)" strokeWidth="14" fill="none" strokeLinecap="round"
                strokeDasharray={dash} strokeDashoffset={offset} className="transition-all duration-1000" />
              <defs>
                <linearGradient id="sg" x1="0" y1="0" x2="1" y2="1">
                  <stop offset="0%" stopColor="oklch(0.74 0.18 155)" />
                  <stop offset="100%" stopColor="oklch(0.68 0.20 285)" />
                </linearGradient>
              </defs>
            </svg>
            <div className="absolute inset-0 flex flex-col items-center justify-center">
              <div className="text-[10px] text-muted-foreground uppercase tracking-wider">Resilience</div>
              <div className="text-6xl font-black">{score}</div>
              <div className="text-xs text-emerald flex items-center gap-1 mt-1"><TrendingUp className="w-3 h-3" /> +6 this week</div>
            </div>
          </div>
          <div className="font-pixel text-[10px] text-gold mt-4">RANK · BUILDER 🏗️</div>
        </div>

        {/* History */}
        <div className="mt-4 glass-strong rounded-3xl p-4">
          <div className="flex justify-between items-center mb-2">
            <div className="text-sm font-bold">12-week history</div>
            <span className="text-[10px] text-muted-foreground">Trending up</span>
          </div>
          <div className="h-32">
            <ResponsiveContainer>
              <LineChart data={history}>
                <XAxis dataKey="d" hide /><YAxis hide domain={[40, 80]} />
                <Tooltip contentStyle={{ background: "oklch(0.21 0.035 260)", border: "1px solid oklch(1 0 0 / 10%)", borderRadius: 12, fontSize: 11 }} />
                <Line dataKey="v" stroke="url(#lg)" strokeWidth={3} dot={{ fill: "oklch(0.72 0.18 155)", r: 3 }} />
                <defs><linearGradient id="lg" x1="0" y1="0" x2="1" y2="0"><stop offset="0%" stopColor="oklch(0.72 0.18 155)" /><stop offset="100%" stopColor="oklch(0.68 0.20 285)" /></linearGradient></defs>
              </LineChart>
            </ResponsiveContainer>
          </div>
        </div>

        {/* Factors */}
        <div className="mt-4 text-sm font-bold">What changed this week</div>
        <div className="mt-2 space-y-2">
          {[
            { i: Shield, t: "Saved RM15 via auto-vault", v: "+3", tone: "emerald" },
            { i: Flame, t: "Maintained 14-day streak", v: "+2", tone: "gold" },
            { i: Radar, t: "Used Smart Radar 4 times", v: "+1.5", tone: "ai" },
            { i: Shield, t: "Late-night Grab on Friday", v: "−0.5", tone: "risk" },
          ].map((f, i) => {
            const c = f.tone === "emerald" ? "bg-grad-emerald" : f.tone === "gold" ? "bg-grad-gold" : f.tone === "ai" ? "bg-grad-ai" : "bg-grad-risk";
            return (
              <div key={i} className="glass rounded-2xl p-3 flex items-center gap-3">
                <div className={`w-10 h-10 rounded-xl ${c} flex items-center justify-center`}><f.i className="w-4 h-4 text-white" /></div>
                <div className="flex-1 text-sm font-medium">{f.t}</div>
                <div className={`text-sm font-bold ${f.v.startsWith("+") ? "text-emerald" : "text-risk"}`}>{f.v}</div>
              </div>
            );
          })}
        </div>

        <div className="mt-4 glass-strong rounded-3xl p-4">
          <div className="text-xs text-muted-foreground uppercase tracking-wider">Next milestone</div>
          <div className="mt-1 text-sm font-bold">Reach 75 to unlock <span className="text-gold">"Guardian"</span> rank.</div>
          <div className="mt-2 h-2 bg-secondary rounded-full overflow-hidden">
            <div className="h-full bg-grad-gold" style={{ width: `${(score/75)*100}%` }} />
          </div>
        </div>
      </div>
    </MobileFrame>
  );
}
