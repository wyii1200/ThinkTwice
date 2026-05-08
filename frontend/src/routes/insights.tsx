import { createFileRoute } from "@tanstack/react-router";
import { Brain, AlertTriangle, TrendingUp, Target, Clock } from "lucide-react";

export const Route = createFileRoute("/insights")({
  head: () => ({ meta: [{ title: "Insights — ThinkTwice" }] }),
  component: InsightsPage,
});

const trend = [40, 55, 38, 62, 45, 70, 48, 30, 52, 60, 35, 42];
const savings = [10, 25, 18, 35, 42, 50, 47];

function InsightsPage() {
  return (
    <div className="space-y-5 px-4 pb-6 pt-5">
      <div>
        <h1 className="text-2xl font-bold">Insights</h1>
        <p className="text-sm text-muted-foreground">Your AI financial intelligence</p>
      </div>

      {/* Personalized */}
      <section className="space-y-2">
        {[
          {
            icon: Clock,
            title: "You overspend most after 10PM",
            body: "62% of impulse purchases happen late at night.",
            tone: "warning",
          },
          {
            icon: TrendingUp,
            title: "Food spending +18% this week",
            body: "Mainly from food delivery (RM86 vs RM58 last week).",
            tone: "warning",
          },
          {
            icon: Target,
            title: "Reduce RM12 today to hit your goal",
            body: "You're on track to save RM800 this month.",
            tone: "primary",
          },
        ].map((i) => (
          <div key={i.title} className="flex gap-3 rounded-2xl bg-card p-3.5 shadow-sm">
            <div
              className={`flex h-10 w-10 shrink-0 items-center justify-center rounded-xl ${
                i.tone === "warning" ? "bg-warning/15 text-warning-foreground" : "bg-primary/15 text-primary"
              }`}
            >
              <i.icon className="h-5 w-5" />
            </div>
            <div>
              <div className="text-sm font-semibold leading-tight">{i.title}</div>
              <div className="mt-0.5 text-xs text-muted-foreground">{i.body}</div>
            </div>
          </div>
        ))}
      </section>

      {/* Spending trend */}
      <section className="rounded-3xl bg-card p-4 shadow-sm">
        <h2 className="mb-3 text-sm font-bold">Spending trend (12 weeks)</h2>
        <div className="flex h-32 items-end gap-1">
          {trend.map((v, i) => (
            <div
              key={i}
              className="flex-1 rounded-t-md transition-all"
              style={{
                height: `${v}%`,
                background:
                  i === trend.length - 1 ? "var(--gradient-primary)" : "var(--muted)",
              }}
            />
          ))}
        </div>
      </section>

      {/* Savings trend */}
      <section className="rounded-3xl bg-card p-4 shadow-sm">
        <h2 className="mb-1 text-sm font-bold">Savings momentum 📈</h2>
        <div className="text-2xl font-bold text-success">+RM 47</div>
        <div className="text-xs text-muted-foreground">vs last week</div>
        <div className="mt-3 flex h-24 items-end gap-1.5">
          {savings.map((v, i) => (
            <div key={i} className="flex flex-1 flex-col items-center gap-1">
              <div
                className="w-full rounded-t-md"
                style={{ height: `${v + 30}%`, background: "var(--gradient-warm)" }}
              />
            </div>
          ))}
        </div>
      </section>

      {/* Risk history */}
      <section className="rounded-3xl bg-card p-4 shadow-sm">
        <h2 className="mb-3 flex items-center gap-2 text-sm font-bold">
          <AlertTriangle className="h-4 w-4 text-warning-foreground" /> Risk alert history
        </h2>
        <div className="space-y-2">
          {[
            { day: "Today", txt: "High food spending risk", color: "warning" },
            { day: "Yesterday", txt: "Late-night impulse buy avoided", color: "success" },
            { day: "2 days ago", txt: "Budget threshold crossed", color: "warning" },
          ].map((r) => (
            <div key={r.day} className="flex items-center gap-3 border-l-2 pl-3" style={{ borderColor: `var(--${r.color})` }}>
              <div className="flex-1">
                <div className="text-sm font-medium">{r.txt}</div>
                <div className="text-[11px] text-muted-foreground">{r.day}</div>
              </div>
            </div>
          ))}
        </div>
      </section>

      <section className="rounded-3xl p-4 text-primary-foreground" style={{ background: "var(--gradient-primary)" }}>
        <div className="flex items-center gap-2">
          <Brain className="h-5 w-5" />
          <h2 className="text-sm font-bold">AI Recommendation</h2>
        </div>
        <p className="mt-2 text-sm leading-relaxed">
          Based on your patterns, set a <b>10PM spending lock</b>. You could save up to{" "}
          <b>RM 120/month</b>.
        </p>
      </section>
    </div>
  );
}
