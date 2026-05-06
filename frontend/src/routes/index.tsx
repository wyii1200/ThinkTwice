import { createFileRoute, Link, useNavigate } from "@tanstack/react-router";
import { useEffect, useState } from "react";
import { Sparkles } from "lucide-react";
import { MobileFrame } from "@/components/MobileFrame";

export const Route = createFileRoute("/")({ component: Splash });

function Splash() {
  const nav = useNavigate();
  const [done, setDone] = useState(false);
  useEffect(() => { const t = setTimeout(() => setDone(true), 1800); return () => clearTimeout(t); }, []);

  return (
    <MobileFrame hideNav hideStatus>
      <div className="relative h-full min-h-[820px] flex flex-col items-center justify-center text-center px-8">
        {/* Particles */}
        {Array.from({ length: 18 }).map((_, i) => (
          <div key={i} className="absolute w-1 h-1 rounded-full bg-ai/70 animate-float"
            style={{ top: `${Math.random()*100}%`, left: `${Math.random()*100}%`, animationDelay: `${Math.random()*4}s` }} />
        ))}

        <div className="relative">
          <div className="absolute inset-0 bg-grad-ai rounded-full animate-pulse-ring" />
          <div className="absolute inset-0 bg-grad-ai rounded-full animate-pulse-ring" style={{ animationDelay: "0.8s" }} />
          <div className="relative w-24 h-24 rounded-3xl bg-grad-ai glow-ai flex items-center justify-center">
            <Sparkles className="w-12 h-12 text-white" />
          </div>
        </div>

        <h1 className="mt-10 text-4xl font-black tracking-tight">Think<span className="text-ai">Twice</span></h1>
        <p className="mt-3 text-sm text-muted-foreground">Financial resilience by design.</p>

        <div className="absolute bottom-12 inset-x-8">
          {done ? (
            <Link to="/welcome" className="block w-full bg-grad-ai glow-ai text-white font-semibold rounded-2xl py-4 animate-slide-up">
              Get Started
            </Link>
          ) : (
            <div className="h-1 bg-secondary rounded-full overflow-hidden">
              <div className="h-full w-1/3 bg-grad-ai shimmer" />
            </div>
          )}
          <button onClick={() => nav({ to: "/dashboard" })} className="mt-3 block w-full text-xs text-muted-foreground hover:text-foreground">Skip to demo →</button>
        </div>
      </div>
    </MobileFrame>
  );
}
