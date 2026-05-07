import { createFileRoute, Link } from "@tanstack/react-router";
import { Area, AreaChart, ResponsiveContainer, Tooltip, XAxis, YAxis } from "recharts";
import { AlertTriangle, Bot, Brain, Flame, MapPin, Moon, Shield, Sparkles } from "lucide-react";
import { MobileFrame } from "@/components/MobileFrame";

export const Route = createFileRoute("/coach")({ component: Coach });

const burn = Array.from({ length: 7 }).map((_, i) => ({
  d: ["M", "T", "W", "T", "F", "S", "S"][i],
  actual: [22, 31, 18, 45, 52, 38, 28][i],
  budget: 45,
}));

function Coach() {
  return (
    <MobileFrame>
      <div className="px-5 pt-3 pb-6">
        <div className="flex items-center gap-2">
          <Link to="/dashboard" className="text-xs text-muted-foreground">
            ← Back
          </Link>
        </div>
        <div className="mt-2 flex items-center gap-2">
          <div className="w-10 h-10 rounded-2xl bg-grad-ai glow-ai flex items-center justify-center">
            <Brain className="w-5 h-5 text-white" />
          </div>
          <div>
            <h1 className="text-xl font-black">AI Coach</h1>
            <div className="text-[11px] text-muted-foreground flex items-center gap-1">
              <Sparkles className="w-3 h-3 text-ai" /> Confidence 94%
            </div>
          </div>
        </div>

        <div className="mt-4 glass rounded-3xl p-4">
          <div className="text-xs font-semibold text-ai uppercase tracking-wider flex items-center gap-1.5">
            <Bot className="w-3.5 h-3.5" /> AI Agent Team
          </div>
          <div className="mt-2 grid grid-cols-2 gap-2 text-[11px]">
            <Agent label="Spending Risk Agent" state="High risk" icon={AlertTriangle} />
            <Agent label="Nudge Agent" state="Message generated" icon={Brain} />
            <Agent label="Smart Radar Agent" state="3 cheaper alternatives" icon={MapPin} />
            <Agent label="Safety Agent" state="Awaiting consent" icon={Shield} />
          </div>
          <div className="mt-3 rounded-2xl bg-white/8 border border-border p-3 text-[12px]">
            <span className="font-semibold text-white">Financial Orchestrator:</span> selects the
            best intervention strategy from nudge, Smart Radar, or micro-saving actions.
          </div>
        </div>

        <div className="mt-4 rounded-3xl p-5 bg-grad-risk relative overflow-hidden">
          <div className="absolute -bottom-8 -right-8 w-40 h-40 bg-white/20 rounded-full blur-3xl" />
          <div className="flex items-center gap-2 text-white/90 text-xs font-semibold uppercase tracking-wider">
            <AlertTriangle className="w-3.5 h-3.5" /> Overspend prediction
          </div>
          <div className="mt-2 text-white text-lg font-bold leading-snug">
            "At this spending rate, you may exceed your weekly budget in 2 days."
          </div>
          <div className="mt-3 grid grid-cols-3 gap-2 relative">
            <Mini label="Burn rate" value="RM34/d" />
            <Mini label="Budget left" value="RM78" />
            <Mini label="Days left" value="4" />
          </div>
        </div>

        <div className="mt-4 glass-strong rounded-3xl p-4">
          <div className="flex justify-between items-center">
            <div className="text-sm font-bold">Daily burn rate</div>
            <span className="text-[10px] text-muted-foreground">Last 7 days</span>
          </div>
          <div className="h-36 mt-2">
            <ResponsiveContainer>
              <AreaChart data={burn}>
                <defs>
                  <linearGradient id="g" x1="0" y1="0" x2="0" y2="1">
                    <stop offset="0%" stopColor="oklch(0.68 0.20 285)" stopOpacity={0.6} />
                    <stop offset="100%" stopColor="oklch(0.68 0.20 285)" stopOpacity={0} />
                  </linearGradient>
                </defs>
                <XAxis
                  dataKey="d"
                  stroke="oklch(0.7 0.02 260)"
                  fontSize={10}
                  axisLine={false}
                  tickLine={false}
                />
                <YAxis hide domain={[0, 60]} />
                <Tooltip
                  contentStyle={{
                    background: "oklch(0.21 0.035 260)",
                    border: "1px solid oklch(1 0 0 / 10%)",
                    borderRadius: 12,
                    fontSize: 11,
                  }}
                />
                <Area
                  dataKey="budget"
                  stroke="oklch(0.74 0.18 155)"
                  strokeDasharray="4 4"
                  fill="transparent"
                  strokeWidth={1.5}
                />
                <Area
                  dataKey="actual"
                  stroke="oklch(0.68 0.20 285)"
                  fill="url(#g)"
                  strokeWidth={2.5}
                />
              </AreaChart>
            </ResponsiveContainer>
          </div>
        </div>

        <div className="mt-4 grid grid-cols-2 gap-3">
          <Risk icon={Moon} label="Late-night spending" v="3 / 7 days" tone="risk" />
          <Risk icon={MapPin} label="Mid Valley risk zone" v="RM 95 spent" tone="risk" />
          <Risk icon={Flame} label="Streak risk" v="Low" tone="emerald" />
          <Risk icon={AlertTriangle} label="Subscription leak" v="RM 14.90" tone="gold" />
        </div>

        <div className="mt-4 glass-strong rounded-3xl p-4">
          <div className="text-xs text-muted-foreground uppercase tracking-wider">
            Suggested action
          </div>
          <div className="mt-1 text-sm font-bold">
            Reduce RM10 spending today to maintain your savings goal.
          </div>
          <div className="mt-3 flex gap-2">
            <Link
              to="/nudge"
              className="flex-1 py-2.5 rounded-2xl bg-grad-emerald text-emerald-foreground font-semibold text-sm text-center"
            >
              Take action
            </Link>
            <button className="px-4 py-2.5 rounded-2xl glass text-sm font-semibold">Snooze</button>
          </div>
        </div>

        <div className="mt-4 glass-strong rounded-3xl p-4">
          <div className="flex justify-between items-center mb-3">
            <div className="text-sm font-bold">Spending heatmap</div>
            <span className="text-[10px] text-muted-foreground">By time of day</span>
          </div>
          <div className="grid grid-cols-7 gap-1">
            {Array.from({ length: 7 * 6 }).map((_, i) => {
              const intensity = Math.random();
              return (
                <div
                  key={i}
                  className="aspect-square rounded"
                  style={{ background: `oklch(0.7 0.22 35 / ${intensity * 0.8 + 0.05})` }}
                />
              );
            })}
          </div>
          <div className="flex justify-between text-[9px] text-muted-foreground mt-1">
            <span>6AM</span>
            <span>12PM</span>
            <span>6PM</span>
            <span>12AM</span>
          </div>
        </div>
      </div>
    </MobileFrame>
  );
}

function Mini({ label, value }: { label: string; value: string }) {
  return (
    <div className="rounded-2xl bg-white/15 backdrop-blur p-2">
      <div className="text-[10px] text-white/70 uppercase tracking-wider">{label}</div>
      <div className="text-sm font-bold text-white">{value}</div>
    </div>
  );
}

function Risk({
  icon: Icon,
  label,
  v,
  tone,
}: {
  icon: React.ComponentType<{ className?: string }>;
  label: string;
  v: string;
  tone: "risk" | "emerald" | "gold";
}) {
  const c = tone === "risk" ? "text-risk" : tone === "emerald" ? "text-emerald" : "text-gold";
  return (
    <div className="glass rounded-2xl p-3">
      <Icon className={`w-4 h-4 ${c}`} />
      <div className="text-[11px] text-muted-foreground mt-1">{label}</div>
      <div className="text-sm font-bold mt-0.5">{v}</div>
    </div>
  );
}

function Agent({
  icon: Icon,
  label,
  state,
}: {
  icon: React.ComponentType<{ className?: string }>;
  label: string;
  state: string;
}) {
  return (
    <div className="rounded-2xl bg-white/8 border border-border p-3">
      <Icon className="w-4 h-4 text-ai" />
      <div className="text-[11px] font-semibold mt-2">{label}</div>
      <div className="text-[10px] text-muted-foreground mt-1">{state}</div>
    </div>
  );
}
