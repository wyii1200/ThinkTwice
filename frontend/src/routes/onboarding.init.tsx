import { createFileRoute, Link } from "@tanstack/react-router";
import { useEffect, useState } from "react";
import { MobileFrame } from "@/components/MobileFrame";
import { Sparkles, Check, ArrowRight } from "lucide-react";
import { PixelCat } from "@/components/PixelCat";

export const Route = createFileRoute("/onboarding/init")({ component: Init });

const steps = [
  "Encrypting GXBank link…",
  "Analyzing 90 days of transactions…",
  "Training behavioral model…",
  "Calibrating Resilience Score…",
  "Waking up your money cat…",
];

function Init() {
  const [done, setDone] = useState(0);
  useEffect(() => {
    if (done >= steps.length) return;
    const t = setTimeout(() => setDone(done + 1), 700);
    return () => clearTimeout(t);
  }, [done]);
  const ready = done >= steps.length;

  return (
    <MobileFrame hideNav>
      <div className="px-6 pt-10 pb-10 flex flex-col h-full min-h-[760px] items-center text-center">
        <div className="relative">
          {!ready && <div className="absolute inset-0 bg-grad-ai rounded-full animate-pulse-ring" />}
          <div className="relative w-20 h-20 rounded-3xl bg-grad-ai glow-ai flex items-center justify-center">
            {ready ? <PixelCat breed="orange-tabby" size={64} /> : <Sparkles className="w-10 h-10 text-white" />}
          </div>
        </div>

        <h1 className="mt-8 text-2xl font-black">{ready ? "You're all set" : "Initializing your guardian"}</h1>
        <p className="mt-2 text-sm text-muted-foreground">{ready ? "Mochi is ready to protect your wallet." : "This takes about 3 seconds."}</p>

        <div className="mt-8 w-full space-y-2">
          {steps.map((s, i) => (
            <div key={i} className={`glass rounded-2xl p-3 flex items-center gap-3 transition ${i < done ? "opacity-100" : "opacity-40"}`}>
              <div className={`w-7 h-7 rounded-full flex items-center justify-center ${i < done ? "bg-emerald" : "bg-secondary"}`}>
                {i < done ? <Check className="w-4 h-4 text-emerald-foreground" /> : <div className="w-2 h-2 rounded-full bg-muted-foreground animate-pulse" />}
              </div>
              <span className="text-sm font-medium text-left">{s}</span>
            </div>
          ))}
        </div>

        {ready && (
          <div className="w-full mt-8 grid grid-cols-3 gap-2 animate-scale-in">
            <Stat label="Resilience" value="50" />
            <Stat label="Streak" value="0d" />
            <Stat label="Vault" value="RM0" />
          </div>
        )}

        {ready && (
          <Link to="/dashboard" className="mt-auto w-full bg-grad-emerald glow-emerald text-emerald-foreground font-bold rounded-2xl py-4 text-center animate-slide-up">
            <span className="inline-flex items-center gap-2">Enter ThinkTwice <ArrowRight className="w-4 h-4" /></span>
          </Link>
        )}
      </div>
    </MobileFrame>
  );
}

function Stat({ label, value }: { label: string; value: string }) {
  return (
    <div className="glass-strong rounded-2xl p-3">
      <div className="text-xl font-black">{value}</div>
      <div className="text-[10px] text-muted-foreground uppercase tracking-wider">{label}</div>
    </div>
  );
}
