import { createFileRoute, useNavigate } from "@tanstack/react-router";
import { useState } from "react";
import catAvatar from "@/assets/cat-avatar.png";
import { Check, ArrowRight, Wallet, Target, TrendingDown } from "lucide-react";
import { Button } from "@/components/ui/button";

export const Route = createFileRoute("/onboarding")({
  head: () => ({ meta: [{ title: "Set up — ThinkTwice" }] }),
  component: OnboardingPage,
});

const breeds = [
  { id: "tabby", name: "Tabby", emoji: "😺" },
  { id: "calico", name: "Calico", emoji: "😻" },
  { id: "black", name: "Shadow", emoji: "🐈‍⬛" },
  { id: "persian", name: "Fluffy", emoji: "😽" },
];
const colors = [
  { id: "mint", val: "oklch(0.78 0.14 160)" },
  { id: "peach", val: "oklch(0.82 0.12 50)" },
  { id: "sky", val: "oklch(0.78 0.12 230)" },
  { id: "rose", val: "oklch(0.78 0.14 10)" },
  { id: "lavender", val: "oklch(0.78 0.12 300)" },
];
const accessories = ["🎩", "👑", "🎀", "🕶️", "🧣", "🎧"];
const outfits = ["Hoodie", "Sweater", "Jacket", "T-shirt"];

function OnboardingPage() {
  const navigate = useNavigate();
  const [step, setStep] = useState(0);
  const [breed, setBreed] = useState("tabby");
  const [color, setColor] = useState("mint");
  const [acc, setAcc] = useState("🎀");
  const [outfit, setOutfit] = useState("Hoodie");
  const [budget, setBudget] = useState(1200);
  const [goal, setGoal] = useState(800);
  const [daily, setDaily] = useState(40);

  const next = () => (step < 2 ? setStep(step + 1) : navigate({ to: "/" }));

  return (
    <div className="flex min-h-screen flex-col px-6 pb-8 pt-8">
      {/* Progress */}
      <div className="mb-6 flex gap-1.5">
        {[0, 1, 2].map((i) => (
          <div
            key={i}
            className={`h-1.5 flex-1 rounded-full transition-all ${
              i <= step ? "" : "bg-muted"
            }`}
            style={i <= step ? { background: "var(--gradient-primary)" } : {}}
          />
        ))}
      </div>

      {/* Avatar preview always shown */}
      <div className="mb-5 flex flex-col items-center">
        <div
          className="relative flex h-32 w-32 items-center justify-center rounded-[2rem]"
          style={{ background: color === "mint" ? "var(--gradient-primary)" : colors.find((c) => c.id === color)?.val }}
        >
          <img src={catAvatar} alt="cat" className="h-28 w-28" />
          <div className="absolute -right-1 -top-1 flex h-10 w-10 items-center justify-center rounded-full bg-card text-xl shadow-md">
            {acc}
          </div>
        </div>
        <div className="mt-2 text-xs font-semibold text-muted-foreground">
          {breeds.find((b) => b.id === breed)?.name} · {outfit}
        </div>
      </div>

      {step === 0 && (
        <div className="flex-1 space-y-5">
          <div>
            <h2 className="text-xl font-bold">Pick your cat</h2>
            <p className="text-xs text-muted-foreground">Your finance buddy for the journey 🐾</p>
          </div>

          <div>
            <Label>Breed</Label>
            <div className="grid grid-cols-4 gap-2">
              {breeds.map((b) => (
                <button
                  key={b.id}
                  onClick={() => setBreed(b.id)}
                  className={`flex flex-col items-center gap-1 rounded-2xl p-3 text-2xl transition-all ${
                    breed === b.id
                      ? "bg-primary/15 ring-2 ring-primary"
                      : "bg-card"
                  }`}
                >
                  {b.emoji}
                  <span className="text-[10px] font-semibold text-foreground">{b.name}</span>
                </button>
              ))}
            </div>
          </div>

          <div>
            <Label>Fur color</Label>
            <div className="flex gap-2.5">
              {colors.map((c) => (
                <button
                  key={c.id}
                  onClick={() => setColor(c.id)}
                  className={`flex h-11 w-11 items-center justify-center rounded-full transition-all ${
                    color === c.id ? "ring-2 ring-foreground ring-offset-2" : ""
                  }`}
                  style={{ background: c.val }}
                >
                  {color === c.id && <Check className="h-4 w-4 text-white" />}
                </button>
              ))}
            </div>
          </div>

          <div>
            <Label>Accessory</Label>
            <div className="grid grid-cols-6 gap-2">
              {accessories.map((a) => (
                <button
                  key={a}
                  onClick={() => setAcc(a)}
                  className={`aspect-square rounded-2xl text-2xl transition-all ${
                    acc === a ? "bg-primary/15 ring-2 ring-primary" : "bg-card"
                  }`}
                >
                  {a}
                </button>
              ))}
            </div>
          </div>

          <div>
            <Label>Starter outfit</Label>
            <div className="grid grid-cols-2 gap-2">
              {outfits.map((o) => (
                <button
                  key={o}
                  onClick={() => setOutfit(o)}
                  className={`rounded-2xl py-3 text-sm font-semibold transition-all ${
                    outfit === o ? "bg-primary/15 text-primary ring-2 ring-primary" : "bg-card text-foreground"
                  }`}
                >
                  {o}
                </button>
              ))}
            </div>
          </div>
        </div>
      )}

      {step === 1 && (
        <div className="flex-1 space-y-5">
          <div>
            <h2 className="text-xl font-bold">Set your numbers</h2>
            <p className="text-xs text-muted-foreground">We'll personalize your plan</p>
          </div>

          <Slider
            icon={Wallet}
            label="Monthly budget"
            value={budget}
            min={300}
            max={5000}
            step={100}
            onChange={setBudget}
            color="primary"
          />
          <Slider
            icon={Target}
            label="Savings goal"
            value={goal}
            min={100}
            max={3000}
            step={50}
            onChange={setGoal}
            color="success"
          />
          <Slider
            icon={TrendingDown}
            label="Daily spending limit"
            value={daily}
            min={10}
            max={200}
            step={5}
            onChange={setDaily}
            color="warning"
          />
        </div>
      )}

      {step === 2 && (
        <div className="flex-1 space-y-3">
          <div>
            <h2 className="text-xl font-bold">Quick personality check</h2>
            <p className="text-xs text-muted-foreground">Optional — helps us coach you better</p>
          </div>
          {[
            "I overspend when I'm stressed 😅",
            "I love a good deal hunt 🎯",
            "I forget to track expenses 📝",
            "I want to save for something specific 🎁",
          ].map((q, i) => (
            <PersonalityRow key={i} text={q} />
          ))}
        </div>
      )}

      <Button
        onClick={next}
        className="mt-6 h-12 w-full rounded-2xl text-sm font-bold"
        style={{ background: "var(--gradient-primary)" }}
      >
        {step === 2 ? "Start saving" : "Continue"}
        <ArrowRight className="ml-1 h-4 w-4" />
      </Button>

      {step > 0 && (
        <button
          onClick={() => setStep(step - 1)}
          className="mt-2 text-center text-xs font-semibold text-muted-foreground"
        >
          Back
        </button>
      )}
    </div>
  );
}

function Label({ children }: { children: React.ReactNode }) {
  return <div className="mb-2 text-xs font-bold uppercase tracking-wider text-muted-foreground">{children}</div>;
}

function Slider({
  icon: Icon,
  label,
  value,
  min,
  max,
  step,
  onChange,
  color,
}: {
  icon: React.ElementType;
  label: string;
  value: number;
  min: number;
  max: number;
  step: number;
  onChange: (v: number) => void;
  color: "primary" | "success" | "warning";
}) {
  const accent =
    color === "primary"
      ? "bg-primary text-primary-foreground"
      : color === "success"
        ? "bg-success text-success-foreground"
        : "bg-warning text-warning-foreground";
  return (
    <div className="rounded-2xl bg-card p-4 shadow-sm">
      <div className="mb-3 flex items-center justify-between">
        <div className="flex items-center gap-2">
          <div className={`flex h-8 w-8 items-center justify-center rounded-xl ${accent}`}>
            <Icon className="h-4 w-4" />
          </div>
          <span className="text-sm font-semibold">{label}</span>
        </div>
        <span className="text-base font-bold">RM {value}</span>
      </div>
      <input
        type="range"
        min={min}
        max={max}
        step={step}
        value={value}
        onChange={(e) => onChange(Number(e.target.value))}
        className="w-full accent-[var(--primary)]"
      />
    </div>
  );
}

function PersonalityRow({ text }: { text: string }) {
  const [v, setV] = useState<"yes" | "no" | null>(null);
  return (
    <div className="flex items-center gap-3 rounded-2xl bg-card p-3.5 shadow-sm">
      <div className="flex-1 text-sm font-medium">{text}</div>
      <button
        onClick={() => setV("yes")}
        className={`h-8 rounded-full px-3 text-xs font-bold transition-all ${
          v === "yes" ? "bg-primary text-primary-foreground" : "bg-muted text-muted-foreground"
        }`}
      >
        Yes
      </button>
      <button
        onClick={() => setV("no")}
        className={`h-8 rounded-full px-3 text-xs font-bold transition-all ${
          v === "no" ? "bg-foreground text-background" : "bg-muted text-muted-foreground"
        }`}
      >
        No
      </button>
    </div>
  );
}
