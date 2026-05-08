import { createFileRoute } from "@tanstack/react-router";
import catAvatar from "@/assets/cat-avatar.png";
import { Settings, Bell, Target, Wallet, ChevronRight, Shirt, Crown, Sparkles } from "lucide-react";
import { Button } from "@/components/ui/button";

export const Route = createFileRoute("/profile")({
  head: () => ({ meta: [{ title: "Profile — ThinkTwice" }] }),
  component: ProfilePage,
});

const tx = [
  { name: "Starbucks", amt: -12, emoji: "☕", time: "2h ago" },
  { name: "Tealive", amt: -9, emoji: "🧋", time: "Yesterday" },
  { name: "GrabFood", amt: -24, emoji: "🍔", time: "Yesterday" },
  { name: "Salary", amt: 2400, emoji: "💰", time: "3 days ago" },
  { name: "Shopee", amt: -45, emoji: "🛍️", time: "4 days ago" },
];

function ProfilePage() {
  return (
    <div className="space-y-5 px-4 pb-6 pt-5">
      {/* Avatar */}
      <section
        className="relative overflow-hidden rounded-3xl p-5 text-primary-foreground"
        style={{ background: "var(--gradient-primary)" }}
      >
        <div className="absolute -right-6 -top-6 h-32 w-32 rounded-full bg-white/10 blur-2xl" />
        <div className="relative flex items-center gap-4">
          <div className="flex h-24 w-24 items-center justify-center rounded-3xl bg-white/20 backdrop-blur-sm">
            <img src={catAvatar} alt="cat avatar" className="h-20 w-20" />
          </div>
          <div>
            <h1 className="text-xl font-bold">Aiman</h1>
            <p className="text-xs opacity-90">Level 4 · Saver</p>
            <div className="mt-2 flex items-center gap-1 rounded-full bg-white/20 px-2 py-0.5 text-[11px] font-semibold backdrop-blur-sm">
              <Sparkles className="h-3 w-3" /> 1,180 pts
            </div>
          </div>
        </div>
      </section>

      {/* Reward shop */}
      <section>
        <div className="mb-2 flex items-center justify-between">
          <h2 className="text-sm font-bold">Reward shop</h2>
          <button className="text-xs font-medium text-primary">View all</button>
        </div>
        <div className="grid grid-cols-3 gap-2.5">
          {[
            { icon: Crown, name: "Crown", price: 200, owned: false },
            { icon: Shirt, name: "Hoodie", price: 150, owned: true },
            { icon: Sparkles, name: "Sparkle", price: 350, owned: false },
          ].map((r) => (
            <div key={r.name} className="rounded-2xl bg-card p-3 text-center shadow-sm">
              <div className="mx-auto flex h-12 w-12 items-center justify-center rounded-2xl bg-accent/30">
                <r.icon className="h-6 w-6 text-accent-foreground" />
              </div>
              <div className="mt-2 text-xs font-semibold">{r.name}</div>
              <div className={`mt-0.5 text-[10px] font-bold ${r.owned ? "text-success" : "text-primary"}`}>
                {r.owned ? "Owned" : `${r.price} pts`}
              </div>
            </div>
          ))}
        </div>
      </section>

      {/* Transactions */}
      <section className="rounded-3xl bg-card p-4 shadow-sm">
        <h2 className="mb-3 text-sm font-bold">Recent transactions</h2>
        <div className="space-y-2.5">
          {tx.map((t, i) => (
            <div key={i} className="flex items-center gap-3">
              <div className="flex h-10 w-10 items-center justify-center rounded-2xl bg-muted text-lg">
                {t.emoji}
              </div>
              <div className="flex-1">
                <div className="text-sm font-semibold">{t.name}</div>
                <div className="text-[11px] text-muted-foreground">{t.time}</div>
              </div>
              <div className={`text-sm font-bold ${t.amt > 0 ? "text-success" : "text-foreground"}`}>
                {t.amt > 0 ? "+" : ""}RM{Math.abs(t.amt)}
              </div>
            </div>
          ))}
        </div>
      </section>

      {/* Settings */}
      <section className="overflow-hidden rounded-3xl bg-card shadow-sm">
        {[
          { icon: Wallet, label: "Budget settings", value: "RM 1,200/mo" },
          { icon: Target, label: "Savings goal", value: "RM 800" },
          { icon: Bell, label: "Notifications", value: "On" },
          { icon: Settings, label: "Auto-save approval", value: "Auto" },
        ].map((s, i) => (
          <button key={s.label} className={`flex w-full items-center gap-3 px-4 py-3.5 ${i > 0 ? "border-t border-border" : ""}`}>
            <div className="flex h-9 w-9 items-center justify-center rounded-xl bg-muted">
              <s.icon className="h-4 w-4 text-foreground" />
            </div>
            <div className="flex-1 text-left text-sm font-medium">{s.label}</div>
            <div className="text-xs text-muted-foreground">{s.value}</div>
            <ChevronRight className="h-4 w-4 text-muted-foreground" />
          </button>
        ))}
      </section>

      <Button variant="outline" className="h-12 w-full rounded-2xl text-destructive">
        Sign out
      </Button>
    </div>
  );
}
