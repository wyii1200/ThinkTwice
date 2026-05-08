import { createFileRoute } from "@tanstack/react-router";
import { Flame, Trophy, Award, Users, Sparkles, CheckCircle2 } from "lucide-react";
import { Button } from "@/components/ui/button";

export const Route = createFileRoute("/challenges")({
  head: () => ({ meta: [{ title: "Quests — ThinkTwice" }] }),
  component: ChallengesPage,
});

const challenges = [
  { title: "3-Day No Overspending", progress: 66, days: "2/3", reward: "150 pts" },
  { title: "7-Day Savings Streak", progress: 100, days: "7/7", reward: "500 pts", done: true },
  { title: "Food Budget Challenge", progress: 40, days: "RM80/200", reward: "Cat hat 🎩" },
];

function ChallengesPage() {
  return (
    <div className="space-y-5 px-4 pb-6 pt-5">
      <div>
        <h1 className="text-2xl font-bold">Quests</h1>
        <p className="text-sm text-muted-foreground">Earn rewards for smart spending</p>
      </div>

      {/* Streaks */}
      <div className="grid grid-cols-2 gap-3">
        <div className="rounded-3xl p-4 text-primary-foreground shadow-[var(--shadow-soft)]" style={{ background: "var(--gradient-warm)" }}>
          <Flame className="h-6 w-6" />
          <div className="mt-2 text-2xl font-bold">7</div>
          <div className="text-[11px] opacity-90">Risk avoidance streak</div>
        </div>
        <div className="rounded-3xl p-4 text-primary-foreground shadow-[var(--shadow-soft)]" style={{ background: "var(--gradient-primary)" }}>
          <Sparkles className="h-6 w-6" />
          <div className="mt-2 text-2xl font-bold">12</div>
          <div className="text-[11px] opacity-90">Smart spending streak</div>
        </div>
      </div>

      {/* Active challenges */}
      <section>
        <h2 className="mb-2 text-sm font-bold">Active quests</h2>
        <div className="space-y-2.5">
          {challenges.map((c) => (
            <div key={c.title} className="rounded-2xl bg-card p-4 shadow-sm">
              <div className="flex items-start justify-between">
                <div className="flex-1">
                  <div className="flex items-center gap-1.5">
                    {c.done && <CheckCircle2 className="h-4 w-4 text-success" />}
                    <span className="text-sm font-semibold">{c.title}</span>
                  </div>
                  <div className="mt-0.5 text-xs text-muted-foreground">{c.days}</div>
                </div>
                <span className="rounded-full bg-accent/30 px-2 py-1 text-[10px] font-bold text-accent-foreground">
                  {c.reward}
                </span>
              </div>
              <div className="mt-2 h-2 overflow-hidden rounded-full bg-muted">
                <div
                  className="h-full rounded-full transition-all"
                  style={{ width: `${c.progress}%`, background: "var(--gradient-primary)" }}
                />
              </div>
              {c.done && (
                <Button className="mt-3 h-9 w-full rounded-xl text-xs font-bold" style={{ background: "var(--gradient-primary)" }}>
                  Claim reward
                </Button>
              )}
            </div>
          ))}
        </div>
      </section>

      {/* Badges */}
      <section className="rounded-3xl bg-card p-4 shadow-sm">
        <div className="mb-3 flex items-center gap-2">
          <Award className="h-4 w-4 text-primary" />
          <h2 className="text-sm font-bold">Badges</h2>
        </div>
        <div className="grid grid-cols-4 gap-3">
          {["🥇", "🔥", "🎯", "💎", "🏆", "⭐", "🌱", "🔒"].map((b, i) => (
            <div
              key={i}
              className={`flex aspect-square items-center justify-center rounded-2xl text-2xl ${
                i < 5 ? "bg-accent/30" : "bg-muted opacity-40"
              }`}
            >
              {b}
            </div>
          ))}
        </div>
      </section>

      {/* Squad */}
      <section className="rounded-3xl bg-card p-4 shadow-sm">
        <div className="mb-3 flex items-center gap-2">
          <Users className="h-4 w-4 text-primary" />
          <h2 className="text-sm font-bold">Squad leaderboard</h2>
        </div>
        <div className="space-y-2">
          {[
            { rank: 1, name: "Mira", pts: 1240, emoji: "👑" },
            { rank: 2, name: "You", pts: 1180, emoji: "😺" },
            { rank: 3, name: "Hafiz", pts: 980, emoji: "🦊" },
            { rank: 4, name: "Lina", pts: 760, emoji: "🐰" },
          ].map((p) => (
            <div
              key={p.name}
              className={`flex items-center gap-3 rounded-2xl p-2.5 ${
                p.name === "You" ? "bg-primary/10" : ""
              }`}
            >
              <div className="flex h-8 w-8 items-center justify-center rounded-full bg-muted text-sm font-bold">
                {p.rank}
              </div>
              <div className="text-xl">{p.emoji}</div>
              <div className="flex-1 text-sm font-semibold">{p.name}</div>
              <div className="flex items-center gap-1 text-sm font-bold text-primary">
                <Trophy className="h-3.5 w-3.5" /> {p.pts}
              </div>
            </div>
          ))}
        </div>
      </section>

      <Button variant="outline" className="h-12 w-full rounded-2xl">
        Customize avatar 🎨
      </Button>
    </div>
  );
}
