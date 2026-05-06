import { createFileRoute } from "@tanstack/react-router";
import { useState } from "react";
import { MobileFrame } from "@/components/MobileFrame";
import { Header, FooterCTA } from "./onboarding.profile";
import { PixelCat, CAT_BREEDS } from "@/components/PixelCat";
import { Sparkles } from "lucide-react";

export const Route = createFileRoute("/onboarding/avatar")({ component: Avatar });

function Avatar() {
  const [breed, setBreed] = useState(CAT_BREEDS[0].id);
  const [name, setName] = useState("Mochi");
  const [hat, setHat] = useState<"crown" | "cap" | null>("cap");
  const [glasses, setGlasses] = useState(true);

  return (
    <MobileFrame hideNav>
      <Header step={3} title="Meet your money cat" />
      <div className="px-6 pb-32">
        <div className="glass-strong rounded-3xl p-6 flex flex-col items-center relative overflow-hidden">
          <div className="absolute inset-0 bg-grad-ai opacity-10" />
          <div className="absolute -top-10 -right-10 w-40 h-40 bg-grad-ai opacity-30 blur-3xl" />
          <div className="relative">
            <PixelCat breed={breed} size={180} hat={hat} glasses={glasses} />
          </div>
          <div className="font-pixel text-[10px] text-gold mt-4 flex items-center gap-1.5"><Sparkles className="w-3 h-3" /> LVL 1 · STARTER</div>
          <input value={name} onChange={(e) => setName(e.target.value)} className="mt-3 bg-transparent text-center text-xl font-bold outline-none border-b border-border focus:border-emerald w-40" />
        </div>

        <Group title="Breed">
          <div className="flex gap-2 overflow-x-auto scrollbar-hide -mx-6 px-6">
            {CAT_BREEDS.map((b) => (
              <button key={b.id} onClick={() => setBreed(b.id)} className={`shrink-0 px-3 py-2 rounded-2xl text-xs font-medium transition flex flex-col items-center gap-1 min-w-[80px] ${breed === b.id ? "bg-grad-ai text-white" : "glass"}`}>
                <PixelCat breed={b.id} size={40} />
                {b.name}
              </button>
            ))}
          </div>
        </Group>

        <Group title="Hat">
          <div className="flex gap-2">
            {[{ k: null, l: "None" }, { k: "cap", l: "Cap" }, { k: "crown", l: "Crown" }].map((h) => (
              <button key={String(h.k)} onClick={() => setHat(h.k as any)} className={`flex-1 py-2.5 rounded-2xl text-sm font-medium ${hat === h.k ? "bg-grad-ai text-white" : "glass"}`}>{h.l}</button>
            ))}
          </div>
        </Group>

        <Group title="Accessory">
          <button onClick={() => setGlasses(!glasses)} className={`w-full py-2.5 rounded-2xl text-sm font-medium ${glasses ? "bg-grad-ai text-white" : "glass"}`}>
            {glasses ? "Pixel Glasses ✓" : "Pixel Glasses"}
          </button>
        </Group>
      </div>
      <FooterCTA to="/onboarding/init" label="Hatch my cat" />
    </MobileFrame>
  );
}

function Group({ title, children }: { title: string; children: React.ReactNode }) {
  return (
    <div className="mt-5">
      <div className="text-xs font-semibold text-muted-foreground uppercase tracking-wider mb-2">{title}</div>
      {children}
    </div>
  );
}
