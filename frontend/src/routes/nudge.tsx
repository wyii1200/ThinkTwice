import { createFileRoute, Link } from "@tanstack/react-router";
import { useState } from "react";
import { MobileFrame } from "@/components/MobileFrame";
import { AlertTriangle, Check, Sparkles } from "lucide-react";
import { PixelCat } from "@/components/PixelCat";

export const Route = createFileRoute("/nudge")({ component: Nudge });

function Nudge() {
  const [done, setDone] = useState(false);

  if (done) return (
    <MobileFrame hideNav>
      <div className="h-full min-h-[760px] flex flex-col items-center justify-center px-8 text-center">
        <div className="relative">
          <div className="absolute inset-0 bg-grad-emerald rounded-full animate-pulse-ring" />
          <div className="relative w-24 h-24 rounded-full bg-grad-emerald glow-emerald flex items-center justify-center">
            <Check className="w-12 h-12 text-emerald-foreground" />
          </div>
        </div>
        <h1 className="mt-8 text-3xl font-black">Great choice!</h1>
        <div className="mt-2 text-emerald text-2xl font-black">RM10 secured 💚</div>
        <p className="mt-3 text-sm text-muted-foreground">Moved to Emergency Vault. Streak +1.</p>

        <div className="mt-8 animate-scale-in">
          <PixelCat breed="orange-tabby" size={140} hat="crown" glasses />
          <div className="font-pixel text-[10px] text-gold mt-3">+25 XP · "DISCIPLINE"</div>
        </div>

        <Link to="/dashboard" className="mt-auto w-full bg-grad-ai glow-ai text-white font-bold rounded-2xl py-4 text-center">Back to dashboard</Link>
      </div>
    </MobileFrame>
  );

  return (
    <MobileFrame hideNav>
      <div className="px-6 pt-6 pb-8 h-full min-h-[760px] flex flex-col">
        <Link to="/dashboard" className="text-xs text-muted-foreground">← Cancel</Link>

        <div className="mt-6 flex items-center gap-2 text-risk text-xs font-bold uppercase tracking-wider">
          <AlertTriangle className="w-4 h-4" /> Real-time nudge
        </div>

        <h1 className="mt-2 text-3xl font-black leading-tight">Think twice before this Starbucks.</h1>
        <p className="mt-3 text-sm text-muted-foreground">Your food spending today is already <span className="text-risk font-bold">35% above target</span>. This RM12 latte will tip you over.</p>

        <div className="mt-5 glass-strong rounded-3xl p-4">
          <div className="text-xs text-muted-foreground uppercase tracking-wider">Today · Food</div>
          <div className="mt-1 flex items-end gap-2">
            <span className="text-3xl font-black text-risk">RM 24.50</span>
            <span className="text-sm text-muted-foreground mb-1">/ RM 18</span>
          </div>
          <div className="mt-2 h-2 bg-secondary rounded-full overflow-hidden">
            <div className="h-full bg-grad-risk" style={{ width: "135%" }} />
          </div>
        </div>

        <div className="mt-4 glass rounded-2xl p-3 flex gap-3 items-center">
          <Sparkles className="w-4 h-4 text-ai shrink-0" />
          <div className="text-[12px]">Mochi suggests: <span className="font-semibold">brew kopi at hostel</span> (saves RM12) or <span className="font-semibold">share with a friend</span> (split RM6).</div>
        </div>

        <div className="mt-auto space-y-2.5">
          <button onClick={() => setDone(true)} className="w-full bg-grad-emerald glow-emerald text-emerald-foreground font-bold rounded-2xl py-4">
            Save RM10 Automatically
          </button>
          <Link to="/radar" className="block w-full glass-strong rounded-2xl py-4 font-semibold text-sm text-center">Find Cheaper Alternatives</Link>
          <button className="w-full text-xs text-muted-foreground py-2">Continue Anyway →</button>
        </div>
      </div>
    </MobileFrame>
  );
}
