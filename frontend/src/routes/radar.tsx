import { createFileRoute } from "@tanstack/react-router";
import { MapPin, ThumbsUp, Coffee, UtensilsCrossed, Route as RouteIcon, Plus, ShoppingBag } from "lucide-react";
import { Button } from "@/components/ui/button";

export const Route = createFileRoute("/radar")({
  head: () => ({ meta: [{ title: "Radar — Smart Savings" }] }),
  component: RadarPage,
});

const deals = [
  { icon: UtensilsCrossed, title: "RM5 Nasi Lemak", place: "Kak Yan Stall · 200m", upvotes: 42, save: "RM7" },
  { icon: Coffee, title: "20% off Coffee", place: "ZUS Coffee · 450m", upvotes: 28, save: "RM3" },
  { icon: ShoppingBag, title: "Buy 1 Free 1 Bread", place: "FamilyMart · 600m", upvotes: 19, save: "RM4" },
];

function RadarPage() {
  return (
    <div className="space-y-5 px-4 pb-6 pt-5">
      <div>
        <h1 className="text-2xl font-bold">Smart Radar</h1>
        <p className="text-sm text-muted-foreground">Deals & savings near you</p>
      </div>

      {/* Savings proof */}
      <div
        className="rounded-3xl p-4 text-primary-foreground shadow-[var(--shadow-soft)]"
        style={{ background: "var(--gradient-primary)" }}
      >
        <div className="text-xs opacity-90">You saved this month</div>
        <div className="mt-1 text-3xl font-bold">RM 47.20</div>
        <div className="mt-1 text-xs opacity-90">via Smart Radar 🎯</div>
      </div>

      {/* Map mock */}
      <div className="relative h-44 overflow-hidden rounded-3xl border border-border bg-muted">
        <div
          className="absolute inset-0 opacity-60"
          style={{
            backgroundImage:
              "linear-gradient(120deg, var(--primary) 0%, transparent 40%), radial-gradient(circle at 30% 50%, var(--accent) 0, transparent 30%), radial-gradient(circle at 70% 60%, var(--primary-glow) 0, transparent 35%)",
          }}
        />
        <div className="absolute inset-0 bg-[linear-gradient(transparent_24px,rgba(0,0,0,0.05)_25px),linear-gradient(90deg,transparent_24px,rgba(0,0,0,0.05)_25px)] bg-[length:25px_25px]" />
        <div className="absolute left-1/2 top-1/2 -translate-x-1/2 -translate-y-1/2">
          <div className="relative">
            <div className="absolute inset-0 animate-ping rounded-full bg-primary/40" />
            <div className="relative flex h-10 w-10 items-center justify-center rounded-full bg-primary text-primary-foreground shadow-lg">
              <MapPin className="h-5 w-5" />
            </div>
          </div>
        </div>
        {[
          { l: "20%", t: "30%" },
          { l: "70%", t: "55%" },
          { l: "40%", t: "70%" },
        ].map((p, i) => (
          <div
            key={i}
            className="absolute h-3 w-3 rounded-full bg-warning ring-2 ring-card"
            style={{ left: p.l, top: p.t }}
          />
        ))}
      </div>

      {/* Cheapest route */}
      <section className="rounded-3xl bg-card p-4 shadow-sm">
        <div className="mb-3 flex items-center gap-2">
          <RouteIcon className="h-4 w-4 text-primary" />
          <h2 className="text-sm font-bold">Cheapest grocery route</h2>
        </div>
        <div className="space-y-2">
          {[
            { stop: "Mydin", item: "Rice 5kg", price: "RM18" },
            { stop: "Tesco", item: "Eggs 30pc", price: "RM12" },
            { stop: "Pasar Borong", item: "Vegetables", price: "RM9" },
          ].map((s, i) => (
            <div key={s.stop} className="flex items-center gap-3">
              <div className="flex h-7 w-7 items-center justify-center rounded-full bg-primary/10 text-xs font-bold text-primary">
                {i + 1}
              </div>
              <div className="flex-1">
                <div className="text-sm font-semibold">{s.stop}</div>
                <div className="text-xs text-muted-foreground">{s.item}</div>
              </div>
              <div className="text-sm font-bold">{s.price}</div>
            </div>
          ))}
        </div>
        <div className="mt-3 flex items-center justify-between rounded-2xl bg-success/15 p-3">
          <span className="text-xs font-semibold text-success">Estimated savings</span>
          <span className="text-base font-bold text-success">RM 14.00</span>
        </div>
        <Button className="mt-3 h-11 w-full rounded-2xl" style={{ background: "var(--gradient-primary)" }}>
          Use this route
        </Button>
      </section>

      {/* Community deals */}
      <section>
        <div className="mb-2 flex items-center justify-between">
          <h2 className="text-sm font-bold">Community deals</h2>
          <button className="flex items-center gap-1 rounded-full bg-primary px-3 py-1 text-xs font-semibold text-primary-foreground">
            <Plus className="h-3 w-3" /> Post
          </button>
        </div>
        <div className="space-y-2">
          {deals.map((d) => (
            <div key={d.title} className="flex items-center gap-3 rounded-2xl bg-card p-3 shadow-sm">
              <div className="flex h-12 w-12 shrink-0 items-center justify-center rounded-2xl bg-warning/20">
                <d.icon className="h-6 w-6 text-warning-foreground" />
              </div>
              <div className="flex-1">
                <div className="text-sm font-semibold">{d.title}</div>
                <div className="text-xs text-muted-foreground">{d.place}</div>
              </div>
              <div className="flex flex-col items-end">
                <span className="rounded-full bg-success/15 px-2 py-0.5 text-[10px] font-bold text-success">
                  Save {d.save}
                </span>
                <div className="mt-1 flex items-center gap-1 text-[11px] text-muted-foreground">
                  <ThumbsUp className="h-3 w-3" /> {d.upvotes}
                </div>
              </div>
            </div>
          ))}
        </div>
      </section>
    </div>
  );
}
