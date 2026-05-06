import { createFileRoute, Link } from "@tanstack/react-router";
import { Fingerprint, Shield, Wallet } from "lucide-react";
import { MobileFrame } from "@/components/MobileFrame";

export const Route = createFileRoute("/welcome")({ component: Welcome });

function Welcome() {
  return (
    <MobileFrame hideNav>
      <div className="px-6 pt-8 pb-10 flex flex-col h-full min-h-[760px]">
        <div className="text-center">
          <div className="inline-flex items-center gap-2 px-3 py-1 rounded-full glass text-xs text-ai">
            <Shield className="w-3 h-3" /> Bank-grade security
          </div>
          <h1 className="mt-6 text-3xl font-black leading-tight">Your AI financial<br/><span className="text-ai">guardian</span> awaits.</h1>
          <p className="mt-3 text-sm text-muted-foreground px-4">Connect GXBank in 30 seconds. ThinkTwice handles the rest.</p>
        </div>

        <div className="mt-8 space-y-3">
          {[
            { icon: Wallet, t: "Real-time spending intelligence", d: "Predicts overspending before it happens" },
            { icon: Shield, t: "Autonomous savings protection", d: "AI moves money to your vault when risk spikes" },
            { icon: Fingerprint, t: "Habit-building rewards", d: "Streaks, squads, and a pixel cat that grows with you" },
          ].map((f, i) => (
            <div key={i} className="glass rounded-2xl p-4 flex gap-3 items-start animate-slide-up" style={{ animationDelay: `${i*80}ms` }}>
              <div className="w-10 h-10 rounded-xl bg-grad-ai flex items-center justify-center shrink-0">
                <f.icon className="w-5 h-5 text-white" />
              </div>
              <div>
                <div className="font-semibold text-sm">{f.t}</div>
                <div className="text-xs text-muted-foreground mt-0.5">{f.d}</div>
              </div>
            </div>
          ))}
        </div>

        <div className="mt-auto pt-8 space-y-3">
          <Link to="/onboarding/profile" className="block w-full bg-grad-emerald glow-emerald text-emerald-foreground font-bold rounded-2xl py-4 text-center">
            Sign in with GXBank
          </Link>
          <button className="w-full glass-strong rounded-2xl py-4 font-semibold text-sm flex items-center justify-center gap-2">
            <Fingerprint className="w-4 h-4 text-ai" /> Use Face ID
          </button>
          <p className="text-center text-[11px] text-muted-foreground">By continuing you agree to our Terms · 256-bit encrypted</p>
        </div>
      </div>
    </MobileFrame>
  );
}
