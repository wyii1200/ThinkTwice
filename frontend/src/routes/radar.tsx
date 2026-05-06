import { createFileRoute } from "@tanstack/react-router";
import { MobileFrame } from "@/components/MobileFrame";
import { MapPin, Star, Navigation, Sparkles } from "lucide-react";

export const Route = createFileRoute("/radar")({ component: Radar });

const pins = [
  { x: 30, y: 28, save: 4, label: "Jaya Grocer" },
  { x: 60, y: 45, save: 14, label: "Tesco" },
  { x: 45, y: 70, save: 7, label: "Mydin" },
  { x: 75, y: 22, save: 3, label: "Family Mart" },
];

function Radar() {
  return (
    <MobileFrame>
      <div className="px-5 pt-3">
        <div className="flex justify-between items-end">
          <div>
            <h1 className="text-2xl font-black">Smart Radar</h1>
            <p className="text-xs text-muted-foreground">Best deals within 2km · Petaling Jaya</p>
          </div>
          <div className="text-right">
            <div className="text-[10px] text-muted-foreground uppercase tracking-wider">Potential save</div>
            <div className="text-2xl font-black text-emerald">RM 14</div>
          </div>
        </div>
      </div>

      {/* Map */}
      <div className="mx-5 mt-3 h-72 rounded-3xl relative overflow-hidden border border-border" style={{ background: "radial-gradient(circle at 50% 50%, oklch(0.25 0.04 260), oklch(0.16 0.03 260))" }}>
        {/* grid */}
        {Array.from({ length: 8 }).map((_, i) => <div key={`h${i}`} className="absolute inset-x-0 border-t border-border/40" style={{ top: `${i*12.5}%` }} />)}
        {Array.from({ length: 8 }).map((_, i) => <div key={`v${i}`} className="absolute inset-y-0 border-l border-border/40" style={{ left: `${i*12.5}%` }} />)}
        {/* route line */}
        <svg className="absolute inset-0 w-full h-full" viewBox="0 0 100 100" preserveAspectRatio="none">
          <path d="M 50 50 Q 40 35 30 28 T 60 45 T 45 70" stroke="oklch(0.74 0.18 155)" strokeWidth="0.6" fill="none" strokeDasharray="2 1.5" />
        </svg>
        {/* user */}
        <div className="absolute" style={{ top: "50%", left: "50%", transform: "translate(-50%,-50%)" }}>
          <div className="absolute inset-0 bg-ai rounded-full animate-pulse-ring w-4 h-4" />
          <div className="relative w-4 h-4 rounded-full bg-ai border-2 border-background" />
        </div>
        {/* pins */}
        {pins.map((p, i) => (
          <div key={i} className="absolute -translate-x-1/2 -translate-y-full" style={{ top: `${p.y}%`, left: `${p.x}%` }}>
            <div className="glass-strong rounded-full px-2 py-0.5 text-[10px] font-bold text-emerald whitespace-nowrap mb-1">−RM{p.save}</div>
            <div className="w-7 h-7 rounded-full bg-grad-emerald glow-emerald flex items-center justify-center mx-auto">
              <MapPin className="w-3.5 h-3.5 text-emerald-foreground" />
            </div>
          </div>
        ))}
      </div>

      <div className="px-5 mt-4 pb-6">
        <div className="glass-strong rounded-3xl p-4">
          <div className="flex items-center gap-2 text-xs text-ai font-semibold"><Sparkles className="w-3.5 h-3.5" /> AI ROUTE · Cheapest combo</div>
          <div className="mt-2 flex items-center gap-3 text-sm font-semibold">
            <span>Jaya Grocer</span><Navigation className="w-3 h-3 text-muted-foreground" />
            <span>Tesco</span><Navigation className="w-3 h-3 text-muted-foreground" />
            <span>Mydin</span>
          </div>
          <div className="text-[11px] text-muted-foreground mt-1">Rice · Eggs & Milk · Veggies</div>
          <div className="mt-3 flex justify-between items-center">
            <div>
              <div className="text-[10px] text-muted-foreground uppercase tracking-wider">Estimated savings</div>
              <div className="text-2xl font-black text-emerald">RM 14.20</div>
            </div>
            <button className="px-4 py-2.5 rounded-2xl bg-grad-emerald text-emerald-foreground font-bold text-sm">Start route</button>
          </div>
        </div>

        <div className="mt-4 text-sm font-bold flex justify-between items-center">
          <span>Community deals</span>
          <span className="text-[10px] text-muted-foreground">Verified by 124 students</span>
        </div>
        <div className="mt-2 space-y-2">
          {[
            { s: "Family Mart", d: "Buy 2 onigiri, free drink", t: 4.8, tag: "Hot" },
            { s: "MyNews", d: "Maggi pack RM2.50 (save RM1)", t: 4.5 },
            { s: "Jaya Grocer", d: "Eggs 30s RM12.90", t: 4.7 },
          ].map((x, i) => (
            <div key={i} className="glass rounded-2xl p-3 flex items-center gap-3">
              <div className="w-10 h-10 rounded-xl bg-grad-emerald flex items-center justify-center"><MapPin className="w-4 h-4 text-emerald-foreground" /></div>
              <div className="flex-1">
                <div className="text-sm font-semibold flex items-center gap-1.5">{x.s} {x.tag && <span className="text-[9px] px-1.5 py-0.5 rounded-full bg-risk/20 text-risk">{x.tag}</span>}</div>
                <div className="text-[11px] text-muted-foreground">{x.d}</div>
              </div>
              <div className="flex items-center gap-1 text-xs"><Star className="w-3 h-3 fill-gold text-gold" /> {x.t}</div>
            </div>
          ))}
        </div>
      </div>
    </MobileFrame>
  );
}
