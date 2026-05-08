import catAvatar from "@/assets/cat-avatar.png";
import { useState } from "react";
import { createFileRoute } from "@tanstack/react-router";
import { Link } from "@tanstack/react-router";
import {
  Wallet,
  TrendingUp,
  Flame,
  Shield,
  Sparkles,
  PiggyBank,
  Map,
  Trophy,
  AlertTriangle,
  X,
  ArrowRight,
} from "lucide-react";
import { Button } from "@/components/ui/button";

export const Route = createFileRoute("/")({
  head: () => ({
    meta: [
      { title: "ThinkTwice 2.0 — Spend smarter" },
      {
        name: "description",
        content: "AI-powered finance coach that helps you save, beat overspending, and earn rewards.",
      },
    ],
  }),
  component: HomePage,
});

const insights = [
  {
    icon: AlertTriangle,
    tone: "warning",
    title: "Food spending 35% above average",
    body: "You've spent RM42 on food today vs your RM31 average.",
  },
  {
    icon: Shield,
    tone: "success",
    title: "You avoided RM47 this week",
    body: "Smart Radar redirected you to cheaper alternatives 3 times.",
  },
  {
    icon: Sparkles,
    tone: "primary",
    title: "You can still save RM20 today",
    body: "Skip the evening bubble tea and stay on streak.",
  },
];

const categories = [
  { name: "Food", value: 42, color: "var(--warning)" },
  { name: "Transport", value: 18, color: "var(--primary)" },
  { name: "Shopping", value: 25, color: "var(--accent)" },
  { name: "Bills", value: 15, color: "var(--success)" },
];

const trend = [30, 45, 28, 60, 35, 52, 41];

function HomePage() {
  const [showAlert, setShowAlert] = useState(true);

  return (
    <div className="space-y-5 px-4 pb-6 pt-5">
      {/* Header */}
      <div className="flex items-center justify-between">
        <div>
          <p className="text-xs text-muted-foreground">Good evening,</p>
          <h1 className="text-xl font-bold text-foreground">Aiman 👋</h1>
        </div>
        <div className="flex h-11 w-11 items-center justify-center overflow-hidden rounded-2xl bg-primary/10">
          <img src={catAvatar} alt="avatar" className="h-10 w-10" />
        </div>
      </div>

      {/* Balance hero */}
      <div
        className="relative overflow-hidden rounded-3xl p-5 text-primary-foreground shadow-[var(--shadow-soft)]"
        style={{ background: "var(--gradient-primary)" }}
      >
        <div className="absolute -right-8 -top-8 h-40 w-40 rounded-full bg-white/10 blur-2xl" />
        <div className="relative">
          <div className="flex items-center gap-1.5 text-xs opacity-90">
            <Wallet className="h-3.5 w-3.5" />
            Current balance
          </div>
          <div className="mt-1 text-3xl font-bold">RM 1,284.50</div>
          <div className="mt-3 flex items-center justify-between text-xs">
            <span>Savings goal</span>
            <span className="font-semibold">RM 480 / RM 800</span>
          </div>
          <div className="mt-1.5 h-2 overflow-hidden rounded-full bg-white/25">
            <div className="h-full rounded-full bg-white" style={{ width: "60%" }} />
          </div>

          <div className="mt-4 grid grid-cols-2 gap-3">
            <div className="rounded-2xl bg-white/15 p-3 backdrop-blur-sm">
              <div className="flex items-center gap-1 text-[11px] opacity-90">
                <Shield className="h-3 w-3" /> Resilience
              </div>
              <div className="mt-0.5 text-lg font-bold">82</div>
            </div>
            <div className="rounded-2xl bg-white/15 p-3 backdrop-blur-sm">
              <div className="flex items-center gap-1 text-[11px] opacity-90">
                <Flame className="h-3 w-3" /> Streak
              </div>
              <div className="mt-0.5 text-lg font-bold">7 days</div>
            </div>
          </div>
        </div>
      </div>

      {/* Quick actions */}
      <div className="grid grid-cols-3 gap-2.5">
        <QuickAction icon={PiggyBank} label="Save Now" tone="primary" />
        <QuickAction icon={Map} label="Smart Radar" tone="accent" to="/radar" />
        <QuickAction icon={Trophy} label="Quests" tone="warning" to="/challenges" />
      </div>

      {/* AI Insights */}
      <section>
        <div className="mb-2 flex items-center justify-between">
          <h2 className="text-sm font-bold text-foreground">AI Insights</h2>
          <Link to="/insights" className="text-xs font-medium text-primary">
            See all
          </Link>
        </div>
        <div className="space-y-2">
          {insights.map((i) => (
            <InsightCard key={i.title} {...i} />
          ))}
        </div>
      </section>

      {/* Mini charts */}
      <section className="rounded-3xl bg-card p-4 shadow-sm">
        <div className="mb-3 flex items-center justify-between">
          <h2 className="text-sm font-bold">This week</h2>
          <span className="rounded-full bg-success/15 px-2 py-0.5 text-[10px] font-semibold text-success">
            <TrendingUp className="mr-0.5 inline h-3 w-3" /> -12%
          </span>
        </div>
        <div className="flex h-24 items-end gap-1.5">
          {trend.map((v, i) => (
            <div key={i} className="flex flex-1 flex-col items-center gap-1">
              <div
                className="w-full rounded-t-md"
                style={{
                  height: `${v}%`,
                  background: i === 5 ? "var(--gradient-primary)" : "var(--muted)",
                }}
              />
              <span className="text-[9px] text-muted-foreground">
                {["M", "T", "W", "T", "F", "S", "S"][i]}
              </span>
            </div>
          ))}
        </div>
        <div className="mt-4 space-y-1.5">
          {categories.map((c) => (
            <div key={c.name}>
              <div className="flex justify-between text-[11px] font-medium">
                <span>{c.name}</span>
                <span className="text-muted-foreground">RM {c.value}</span>
              </div>
              <div className="mt-0.5 h-1.5 overflow-hidden rounded-full bg-muted">
                <div
                  className="h-full rounded-full"
                  style={{ width: `${c.value}%`, background: c.color }}
                />
              </div>
            </div>
          ))}
        </div>
      </section>

      {/* Squad */}
      <section className="rounded-3xl bg-card p-4 shadow-sm">
        <div className="mb-3 flex items-center justify-between">
          <h2 className="text-sm font-bold">Squad leaderboard</h2>
          <Link to="/challenges" className="text-xs font-medium text-primary">
            View
          </Link>
        </div>
        <div className="space-y-2">
          {[
            { rank: 1, name: "Mira", pts: 1240, you: false },
            { rank: 2, name: "You", pts: 1180, you: true },
            { rank: 3, name: "Hafiz", pts: 980, you: false },
          ].map((p) => (
            <div
              key={p.name}
              className={`flex items-center gap-3 rounded-2xl p-2.5 ${
                p.you ? "bg-primary/10" : ""
              }`}
            >
              <div className="flex h-8 w-8 items-center justify-center rounded-full bg-muted text-sm font-bold">
                {p.rank}
              </div>
              <div className="flex-1 text-sm font-semibold">{p.name}</div>
              <div className="text-sm font-bold text-primary">{p.pts} pts</div>
            </div>
          ))}
        </div>
      </section>

      {showAlert && <AIInterventionModal onClose={() => setShowAlert(false)} />}
    </div>
  );
}

function QuickAction({
  icon: Icon,
  label,
  tone,
  to,
}: {
  icon: React.ElementType;
  label: string;
  tone: "primary" | "accent" | "warning";
  to?: "/radar" | "/challenges";
}) {
  const bg =
    tone === "primary"
      ? "bg-primary/10 text-primary"
      : tone === "accent"
        ? "bg-accent/30 text-accent-foreground"
        : "bg-warning/20 text-warning-foreground";
  const inner = (
    <div className={`flex flex-col items-center gap-1.5 rounded-2xl p-3 ${bg}`}>
      <Icon className="h-5 w-5" />
      <span className="text-[11px] font-semibold">{label}</span>
    </div>
  );
  return to ? <Link to={to}>{inner}</Link> : <button className="w-full">{inner}</button>;
}

function InsightCard({
  icon: Icon,
  tone,
  title,
  body,
}: {
  icon: React.ElementType;
  tone: string;
  title: string;
  body: string;
}) {
  const colors: Record<string, string> = {
    warning: "bg-warning/15 text-warning-foreground",
    success: "bg-success/15 text-success",
    primary: "bg-primary/15 text-primary",
  };
  return (
    <div className="flex gap-3 rounded-2xl bg-card p-3.5 shadow-sm">
      <div className={`flex h-10 w-10 shrink-0 items-center justify-center rounded-xl ${colors[tone]}`}>
        <Icon className="h-5 w-5" />
      </div>
      <div className="flex-1">
        <div className="text-sm font-semibold leading-tight">{title}</div>
        <div className="mt-0.5 text-xs text-muted-foreground">{body}</div>
      </div>
    </div>
  );
}

function AIInterventionModal({ onClose }: { onClose: () => void }) {
  return (
    <div className="fixed inset-0 z-50 flex items-end justify-center bg-black/50 p-4 backdrop-blur-sm md:items-center">
      <div className="w-full max-w-md animate-in slide-in-from-bottom duration-300 rounded-3xl bg-card p-5 shadow-xl">
        <div className="flex items-start justify-between">
          <div className="flex items-center gap-2.5">
            <div className="flex h-11 w-11 items-center justify-center rounded-2xl bg-warning/20">
              <AlertTriangle className="h-6 w-6 text-warning-foreground" />
            </div>
            <div>
              <div className="text-[10px] font-bold uppercase tracking-wider text-warning-foreground">
                Risk detected
              </div>
              <h3 className="text-base font-bold">High Spending Risk</h3>
            </div>
          </div>
          <button onClick={onClose} className="rounded-full p-1 text-muted-foreground">
            <X className="h-5 w-5" />
          </button>
        </div>
        <div className="mt-4 rounded-2xl bg-muted/60 p-3">
          <p className="text-sm leading-relaxed">
            Your <b>food spending today</b> is already <b>42% above average</b>. Save RM8 now to
            maintain your streak 🔥
          </p>
        </div>
        <div className="mt-4 space-y-2">
          <Button
            onClick={onClose}
            className="h-12 w-full rounded-2xl text-sm font-bold"
            style={{ background: "var(--gradient-primary)" }}
          >
            <PiggyBank className="mr-1 h-4 w-4" /> Save RM8 now
          </Button>
          <Button
            onClick={onClose}
            variant="secondary"
            className="h-11 w-full rounded-2xl text-sm font-semibold"
          >
            Find cheaper alternatives <ArrowRight className="ml-1 h-4 w-4" />
          </Button>
          <button onClick={onClose} className="w-full py-1 text-xs text-muted-foreground">
            Ignore
          </button>
        </div>
      </div>
    </div>
  );
}
