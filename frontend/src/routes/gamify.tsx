import { createFileRoute } from "@tanstack/react-router";
import { useState } from "react";
import { MobileFrame } from "@/components/MobileFrame";
import { PixelCat } from "@/components/PixelCat";
import { Flame, Trophy, Sparkles, Lock } from "lucide-react";

export const Route = createFileRoute("/gamify")({ component: Gamify });

function Gamify() {
  const [tab, setTab] = useState<"quests" | "shop">("quests");

  return (
    <MobileFrame>
      <div className="px-5 pt-3 pb-6">
        <h1 className="text-2xl font-black">Quests</h1>

        {/* Cat hero */}
        <div className="mt-3 glass-strong rounded-3xl p-5 relative overflow-hidden">
          <div className="absolute inset-0 bg-grad-ai opacity-15" />
          <div className="absolute -top-10 -right-10 w-40 h-40 bg-grad-gold opacity-20 blur-3xl" />
          <div className="relative flex items-center gap-4">
            <div className="bg-secondary/60 rounded-2xl p-3 border border-border">
              <PixelCat breed="orange-tabby" size={96} hat="crown" glasses />
            </div>
            <div>
              <div className="font-pixel text-[10px] text-gold">LEVEL 4</div>
              <div className="text-xl font-black mt-1">Mochi the Disciplined</div>
              <div className="flex items-center gap-1 text-xs text-risk mt-1"><Flame className="w-3.5 h-3.5" /> 14-day streak</div>
              <div className="mt-2 h-1.5 w-32 bg-secondary rounded-full overflow-hidden">
                <div className="h-full bg-grad-gold" style={{ width: "62%" }} />
              </div>
              <div className="text-[10px] text-muted-foreground mt-0.5">620 / 1000 XP</div>
            </div>
          </div>
          <div className="relative grid grid-cols-3 gap-2 mt-4">
            <Stat v="14🔥" l="Streak" />
            <Stat v="9" l="Badges" />
            <Stat v="2,840" l="Coins" />
          </div>
        </div>

        {/* Tabs */}
        <div className="mt-4 glass rounded-2xl p-1 grid grid-cols-2">
          {(["quests", "shop"] as const).map(t => (
            <button key={t} onClick={() => setTab(t)} className={`py-2 rounded-xl text-sm font-semibold capitalize ${tab === t ? "bg-grad-ai text-white" : "text-muted-foreground"}`}>{t === "quests" ? "Weekly quests" : "Cat shop"}</button>
          ))}
        </div>

        {tab === "quests" ? (
          <div className="mt-4 space-y-3">
            <Quest title="Skip 3 kopi runs" reward="+150 XP" prog={66} sub="2 / 3 done" />
            <Quest title="Hit RM200 in vault" reward="+300 XP · Hat" prog={85} sub="RM170 / 200" />
            <Quest title="Use Smart Radar 5x" reward="+80 XP" prog={40} sub="2 / 5" />
            <Quest title="No late-night spending (9pm–2am)" reward="+200 XP · Rare skin" prog={100} sub="Claim now!" claim />

            <div className="text-sm font-bold mt-4 flex items-center gap-1.5"><Trophy className="w-4 h-4 text-gold" /> Recent badges</div>
            <div className="grid grid-cols-4 gap-2">
              {[
                { e: "🏦", n: "First Save", r: "Common" },
                { e: "🌙", n: "Night Owl Slayer", r: "Rare" },
                { e: "🛒", n: "Smart Shopper", r: "Epic" },
                { e: "👑", n: "Discipline", r: "Legendary" },
              ].map(b => (
                <div key={b.n} className="glass rounded-2xl p-2 text-center">
                  <div className="text-2xl">{b.e}</div>
                  <div className="text-[10px] font-semibold mt-1 leading-tight">{b.n}</div>
                  <div className={`text-[9px] mt-0.5 ${b.r === "Legendary" ? "text-gold" : b.r === "Epic" ? "text-ai" : "text-muted-foreground"}`}>{b.r}</div>
                </div>
              ))}
            </div>
          </div>
        ) : (
          <div className="mt-4">
            <div className="text-xs text-muted-foreground mb-2">Spend coins to dress up Mochi.</div>
            <div className="grid grid-cols-3 gap-2">
              {shopItems.map((it, i) => (
                <div key={i} className="glass-strong rounded-2xl p-2 flex flex-col items-center text-center">
                  <div className="bg-secondary/50 rounded-xl p-2 w-full flex justify-center">
                    {it.preview}
                  </div>
                  <div className="text-[10px] font-semibold mt-1.5">{it.name}</div>
                  <div className={`text-[9px] mt-0.5 ${it.r === "Legendary" ? "text-gold" : it.r === "Rare" ? "text-ai" : "text-muted-foreground"}`}>{it.r}</div>
                  <button disabled={it.locked} className={`mt-1 w-full text-[10px] font-bold py-1 rounded-lg ${it.locked ? "bg-secondary text-muted-foreground" : "bg-grad-gold text-gold-foreground"}`}>
                    {it.locked ? <Lock className="w-3 h-3 inline" /> : `${it.cost} 🪙`}
                  </button>
                </div>
              ))}
            </div>
          </div>
        )}
      </div>
    </MobileFrame>
  );
}

const shopItems = [
  { name: "Pixel Cap", r: "Common", cost: 100, locked: false, preview: <PixelCat breed="orange-tabby" size={48} hat="cap" /> },
  { name: "Crown", r: "Legendary", cost: 1500, locked: false, preview: <PixelCat breed="persian" size={48} hat="crown" /> },
  { name: "Glasses", r: "Rare", cost: 400, locked: false, preview: <PixelCat breed="tuxedo" size={48} glasses /> },
  { name: "Royal Set", r: "Legendary", cost: 2500, locked: true, preview: <PixelCat breed="ragdoll" size={48} hat="crown" glasses /> },
  { name: "Ninja", r: "Epic", cost: 800, locked: true, preview: <PixelCat breed="tuxedo" size={48} /> },
  { name: "Sushi BG", r: "Rare", cost: 350, locked: false, preview: <PixelCat breed="calico" size={48} /> },
];

function Stat({ v, l }: { v: string; l: string }) {
  return <div className="rounded-2xl bg-white/10 backdrop-blur p-2 text-center"><div className="text-sm font-black">{v}</div><div className="text-[9px] text-muted-foreground uppercase tracking-wider">{l}</div></div>;
}

function Quest({ title, reward, prog, sub, claim }: { title: string; reward: string; prog: number; sub: string; claim?: boolean }) {
  return (
    <div className="glass-strong rounded-2xl p-3">
      <div className="flex justify-between items-start">
        <div>
          <div className="text-sm font-bold">{title}</div>
          <div className="text-[11px] text-gold font-semibold mt-0.5 flex items-center gap-1"><Sparkles className="w-3 h-3" /> {reward}</div>
        </div>
        {claim && <button className="text-[10px] font-bold px-2.5 py-1 rounded-full bg-grad-gold text-gold-foreground">CLAIM</button>}
      </div>
      <div className="mt-2 h-1.5 bg-secondary rounded-full overflow-hidden">
        <div className={`h-full ${prog === 100 ? "bg-grad-gold" : "bg-grad-emerald"}`} style={{ width: `${prog}%` }} />
      </div>
      <div className="text-[10px] text-muted-foreground mt-1">{sub}</div>
    </div>
  );
}
