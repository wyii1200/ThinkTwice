import { createFileRoute, useNavigate } from "@tanstack/react-router";
import { useEffect } from "react";
import catAvatar from "@/assets/cat-avatar.png";
import { Sparkles } from "lucide-react";

export const Route = createFileRoute("/splash")({
  component: SplashPage,
});

function SplashPage() {
  const navigate = useNavigate();
  useEffect(() => {
    const t = setTimeout(() => navigate({ to: "/login" }), 2200);
    return () => clearTimeout(t);
  }, [navigate]);

  return (
    <div
      className="flex min-h-screen flex-col items-center justify-center px-6 text-primary-foreground"
      style={{ background: "var(--gradient-primary)" }}
    >
      <div className="absolute inset-0 overflow-hidden">
        <div className="absolute -left-20 top-20 h-64 w-64 animate-pulse rounded-full bg-white/10 blur-3xl" />
        <div className="absolute -right-16 bottom-32 h-72 w-72 animate-pulse rounded-full bg-accent/30 blur-3xl" />
      </div>
      <div className="relative flex flex-col items-center gap-6">
        <div className="relative">
          <div className="absolute inset-0 animate-ping rounded-full bg-white/30" />
          <div className="relative flex h-32 w-32 items-center justify-center rounded-[2rem] bg-white/20 backdrop-blur-sm">
            <img src={catAvatar} alt="ThinkTwice" className="h-28 w-28" />
          </div>
        </div>
        <div className="text-center">
          <div className="flex items-center justify-center gap-1.5">
            <Sparkles className="h-5 w-5" />
            <h1 className="text-3xl font-bold tracking-tight">ThinkTwice</h1>
          </div>
          <p className="mt-2 text-sm opacity-90">
            Financial resilience becomes automatic.
          </p>
        </div>
        <div className="mt-6 flex gap-1.5">
          {[0, 1, 2].map((i) => (
            <div
              key={i}
              className="h-2 w-2 animate-bounce rounded-full bg-white"
              style={{ animationDelay: `${i * 0.15}s` }}
            />
          ))}
        </div>
      </div>
    </div>
  );
}
