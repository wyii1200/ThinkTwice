import { createFileRoute, useNavigate, Link } from "@tanstack/react-router";
import { useState } from "react";
import { Mail, Lock, Fingerprint, ArrowRight, Eye, EyeOff } from "lucide-react";
import { Button } from "@/components/ui/button";
import catAvatar from "@/assets/cat-avatar.png";

export const Route = createFileRoute("/login")({
  head: () => ({ meta: [{ title: "Sign in — ThinkTwice" }] }),
  component: LoginPage,
});

function LoginPage() {
  const navigate = useNavigate();
  const [mode, setMode] = useState<"login" | "signup">("login");
  const [showPw, setShowPw] = useState(false);

  const submit = (e: React.FormEvent) => {
    e.preventDefault();
    navigate({ to: "/onboarding" });
  };

  return (
    <div className="flex min-h-screen flex-col px-6 pb-8 pt-10">
      {/* Illustration */}
      <div
        className="relative mx-auto mb-6 flex h-40 w-40 items-center justify-center rounded-[2rem] shadow-[var(--shadow-soft)]"
        style={{ background: "var(--gradient-primary)" }}
      >
        <div className="absolute -right-2 -top-2 h-8 w-8 animate-bounce rounded-full bg-accent" style={{ animationDuration: "2s" }} />
        <div className="absolute -bottom-2 -left-3 h-6 w-6 animate-bounce rounded-full bg-warning" style={{ animationDuration: "2.5s" }} />
        <img src={catAvatar} alt="cat" className="h-32 w-32" />
      </div>

      <h1 className="text-center text-2xl font-bold">
        {mode === "login" ? "Welcome back" : "Get started"}
      </h1>
      <p className="mt-1 text-center text-sm text-muted-foreground">
        {mode === "login"
          ? "Sign in to continue your savings streak"
          : "Build financial resilience, one tap at a time"}
      </p>

      {/* GXBank */}
      <button
        onClick={() => navigate({ to: "/onboarding" })}
        className="mt-6 flex h-12 w-full items-center justify-center gap-2 rounded-2xl bg-foreground text-sm font-bold text-background"
      >
        <span className="flex h-5 w-5 items-center justify-center rounded-full bg-accent text-[10px] font-black text-accent-foreground">
          GX
        </span>
        Continue with GXBank
      </button>

      <div className="my-4 flex items-center gap-3">
        <div className="h-px flex-1 bg-border" />
        <span className="text-[11px] font-medium text-muted-foreground">OR</span>
        <div className="h-px flex-1 bg-border" />
      </div>

      <form onSubmit={submit} className="space-y-3">
        <div className="relative">
          <Mail className="absolute left-3 top-1/2 h-4 w-4 -translate-y-1/2 text-muted-foreground" />
          <input
            type="email"
            required
            placeholder="Email"
            defaultValue="aiman@think.co"
            className="h-12 w-full rounded-2xl border border-border bg-card pl-10 pr-3 text-sm outline-none focus:border-primary"
          />
        </div>
        <div className="relative">
          <Lock className="absolute left-3 top-1/2 h-4 w-4 -translate-y-1/2 text-muted-foreground" />
          <input
            type={showPw ? "text" : "password"}
            required
            placeholder="Password"
            defaultValue="••••••••"
            className="h-12 w-full rounded-2xl border border-border bg-card pl-10 pr-10 text-sm outline-none focus:border-primary"
          />
          <button
            type="button"
            onClick={() => setShowPw(!showPw)}
            className="absolute right-3 top-1/2 -translate-y-1/2 text-muted-foreground"
          >
            {showPw ? <EyeOff className="h-4 w-4" /> : <Eye className="h-4 w-4" />}
          </button>
        </div>

        {mode === "login" && (
          <div className="text-right">
            <button type="button" className="text-xs font-semibold text-primary">
              Forgot password?
            </button>
          </div>
        )}

        <Button
          type="submit"
          className="h-12 w-full rounded-2xl text-sm font-bold"
          style={{ background: "var(--gradient-primary)" }}
        >
          {mode === "login" ? "Sign in" : "Get started"}
          <ArrowRight className="ml-1 h-4 w-4" />
        </Button>
      </form>

      <button
        onClick={() => navigate({ to: "/onboarding" })}
        className="mt-3 flex h-12 w-full items-center justify-center gap-2 rounded-2xl border-2 border-dashed border-primary/40 bg-primary/5 text-sm font-bold text-primary"
      >
        <Fingerprint className="h-5 w-5" />
        Use biometric login
      </button>

      <p className="mt-6 text-center text-xs text-muted-foreground">
        {mode === "login" ? "New to ThinkTwice? " : "Already have an account? "}
        <button
          type="button"
          onClick={() => setMode(mode === "login" ? "signup" : "login")}
          className="font-bold text-primary"
        >
          {mode === "login" ? "Create account" : "Sign in"}
        </button>
      </p>

      <Link to="/" className="mt-2 text-center text-[11px] text-muted-foreground">
        Skip for now
      </Link>
    </div>
  );
}
