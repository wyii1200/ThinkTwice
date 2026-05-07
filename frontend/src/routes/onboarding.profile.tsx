import { createFileRoute, Link } from "@tanstack/react-router";
import { useState } from "react";
import { ArrowRight, ChevronLeft } from "lucide-react";
import { MobileFrame } from "@/components/MobileFrame";

export const Route = createFileRoute("/onboarding/profile")({ component: Profile });

const incomes = ["< RM500", "RM500 – 1,500", "RM1,500 – 3,000", "RM3,000+"];
const habits = ["Saver", "Balanced", "Spender", "YOLO"];
const goals = ["Emergency fund", "First car", "Travel", "Tech gear", "Investment"];
const concerns = ["Late-night food", "Online shopping", "Subscriptions", "Cafés", "Grab rides"];

function Profile() {
  const [income, setIncome] = useState(incomes[1]);
  const [habit, setHabit] = useState(habits[1]);
  const [g, setG] = useState<string[]>(["Emergency fund"]);
  const [c, setC] = useState<string[]>(["Late-night food"]);

  const toggle = (arr: string[], v: string, set: (a: string[]) => void) =>
    set(arr.includes(v) ? arr.filter((x) => x !== v) : [...arr, v]);

  return (
    <MobileFrame hideNav>
      <Header step={1} title="Financial profile" />
      <div className="px-6 space-y-6 pb-32">
        <Section label="Monthly income">
          <Pills options={incomes} value={income} onChange={setIncome} />
        </Section>
        <Section label="Spending habit">
          <Pills options={habits} value={habit} onChange={setHabit} />
        </Section>
        <Section label="Top savings goals">
          <Pills options={goals} multi value={g} onMulti={(v) => toggle(g, v, setG)} />
        </Section>
        <Section label="Biggest spending concerns">
          <Pills options={concerns} multi value={c} onMulti={(v) => toggle(c, v, setC)} />
        </Section>
      </div>
      <FooterCTA to="/onboarding/budget" />
    </MobileFrame>
  );
}

export function Header({
  step,
  title,
  total = 4,
}: {
  step: number;
  title: string;
  total?: number;
}) {
  return (
    <div className="px-6 pt-4 pb-6">
      <div className="flex items-center justify-between mb-4">
        <Link to="/gxbank" className="w-9 h-9 rounded-xl glass flex items-center justify-center">
          <ChevronLeft className="w-5 h-5" />
        </Link>
        <span className="text-xs text-muted-foreground">
          Step {step} of {total}
        </span>
        <div className="w-9" />
      </div>
      <div className="h-1.5 bg-secondary rounded-full overflow-hidden">
        <div
          className="h-full bg-grad-ai transition-all duration-500"
          style={{ width: `${(step / total) * 100}%` }}
        />
      </div>
      <h1 className="mt-5 text-2xl font-black">{title}</h1>
    </div>
  );
}

function Section({ label, children }: { label: string; children: React.ReactNode }) {
  return (
    <div>
      <div className="text-xs font-semibold text-muted-foreground uppercase tracking-wider mb-2">
        {label}
      </div>
      {children}
    </div>
  );
}

function Pills({
  options,
  value,
  onChange,
  multi,
  onMulti,
}: {
  options: string[];
  value: string | string[];
  onChange?: (v: string) => void;
  multi?: boolean;
  onMulti?: (v: string) => void;
}) {
  return (
    <div className="flex flex-wrap gap-2">
      {options.map((o) => {
        const active = multi ? (value as string[]).includes(o) : value === o;
        return (
          <button
            key={o}
            onClick={() => (multi ? onMulti?.(o) : onChange?.(o))}
            className={`px-4 py-2.5 rounded-2xl text-sm font-medium transition ${active ? "bg-grad-ai text-white glow-ai" : "glass text-foreground/80"}`}
          >
            {o}
          </button>
        );
      })}
    </div>
  );
}

export function FooterCTA({ to, label = "Continue" }: { to: string; label?: string }) {
  return (
    <div className="absolute bottom-0 inset-x-0 p-6 bg-gradient-to-t from-background via-background/95 to-transparent">
      <Link
        to={to}
        className="block w-full bg-grad-emerald glow-emerald text-emerald-foreground font-bold rounded-2xl py-4 text-center"
      >
        <span className="inline-flex items-center gap-2">
          {label} <ArrowRight className="w-4 h-4" />
        </span>
      </Link>
    </div>
  );
}
