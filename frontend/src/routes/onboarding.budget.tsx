import { createFileRoute } from "@tanstack/react-router";
import { useState } from "react";
import { MobileFrame } from "@/components/MobileFrame";
import { Header, FooterCTA } from "./onboarding.profile";
import { Coffee, ShoppingBag, Bus, Film, BookOpen } from "lucide-react";

export const Route = createFileRoute("/onboarding/budget")({ component: Budget });

function Budget() {
  const [daily, setDaily] = useState(45);
  const [save, setSave] = useState(20);

  const cats = [
    { icon: Coffee, name: "Food & Drinks", v: 18 },
    { icon: ShoppingBag, name: "Shopping", v: 10 },
    { icon: Bus, name: "Transport", v: 8 },
    { icon: Film, name: "Entertainment", v: 5 },
    { icon: BookOpen, name: "Study", v: 4 },
  ];

  return (
    <MobileFrame hideNav>
      <Header step={2} title="Budget preferences" />
      <div className="px-6 space-y-6 pb-32">
        <div className="glass-strong rounded-3xl p-5">
          <div className="flex justify-between items-end">
            <span className="text-xs text-muted-foreground uppercase tracking-wider">Daily budget</span>
            <span className="text-3xl font-black">RM{daily}</span>
          </div>
          <input type="range" min={10} max={150} value={daily} onChange={(e) => setDaily(+e.target.value)}
            className="w-full mt-4 accent-emerald" />
        </div>

        <div className="glass-strong rounded-3xl p-5">
          <div className="flex justify-between items-end mb-1">
            <span className="text-xs text-muted-foreground uppercase tracking-wider">Auto-save % of income</span>
            <span className="text-3xl font-black text-emerald">{save}%</span>
          </div>
          <input type="range" min={5} max={50} value={save} onChange={(e) => setSave(+e.target.value)}
            className="w-full mt-4 accent-emerald" />
          <div className="text-xs text-muted-foreground mt-2">≈ RM{Math.round(2000*save/100)} saved every payday</div>
        </div>

        <div>
          <div className="text-xs font-semibold text-muted-foreground uppercase tracking-wider mb-3">Category limits / day</div>
          <div className="space-y-2">
            {cats.map((c) => (
              <div key={c.name} className="glass rounded-2xl p-3 flex items-center gap-3">
                <div className="w-9 h-9 rounded-xl bg-secondary flex items-center justify-center"><c.icon className="w-4 h-4 text-ai" /></div>
                <div className="flex-1 text-sm font-medium">{c.name}</div>
                <div className="text-sm font-bold">RM{c.v}</div>
              </div>
            ))}
          </div>
        </div>

        <div className="flex items-center justify-between glass rounded-2xl p-4">
          <div>
            <div className="text-sm font-semibold">Spending alerts</div>
            <div className="text-xs text-muted-foreground">Real-time risk nudges</div>
          </div>
          <div className="w-11 h-6 rounded-full bg-emerald p-0.5 flex justify-end"><div className="w-5 h-5 rounded-full bg-white" /></div>
        </div>
      </div>
      <FooterCTA to="/onboarding/avatar" />
    </MobileFrame>
  );
}
