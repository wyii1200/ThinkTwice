import { createFileRoute, Link } from "@tanstack/react-router";
import { MobileFrame } from "@/components/MobileFrame";
import { ArrowUp, MessageCircle, Plus, Trophy } from "lucide-react";
import { PixelCat } from "@/components/PixelCat";

export const Route = createFileRoute("/squad")({ component: Squad });

function Squad() {
  return (
    <MobileFrame>
      <div className="px-5 pt-3 pb-6">
        <div className="flex items-center gap-2"><Link to="/dashboard" className="text-xs text-muted-foreground">← Back</Link></div>
        <h1 className="mt-2 text-2xl font-black">Squad · Resilience Pack</h1>
        <p className="text-xs text-muted-foreground">5 friends from Universiti Malaya</p>

        <div className="mt-4 rounded-3xl p-5 bg-grad-emerald glow-emerald text-emerald-foreground relative overflow-hidden">
          <div className="absolute -bottom-6 -right-6 w-32 h-32 bg-white/20 rounded-full blur-2xl" />
          <div className="relative">
            <div className="text-[11px] uppercase tracking-wider opacity-70">This week's squad save</div>
            <div className="text-4xl font-black mt-1">RM 250.40</div>
            <div className="text-xs opacity-80 mt-1">+18% vs last week 🔥</div>
          </div>
        </div>

        <div className="mt-5 text-sm font-bold flex items-center gap-1.5"><Trophy className="w-4 h-4 text-gold" /> Leaderboard</div>
        <div className="mt-2 glass-strong rounded-3xl divide-y divide-border overflow-hidden">
          {[
            { n: "Aiman (you)", b: "orange-tabby", s: 92, save: 78 },
            { n: "Sarah", b: "calico", s: 88, save: 64 },
            { n: "Daniel", b: "tuxedo", s: 81, save: 52 },
            { n: "Mei Ling", b: "siamese", s: 76, save: 41 },
            { n: "Iqbal", b: "british-shorthair", s: 70, save: 14 },
          ].map((m, i) => (
            <div key={m.n} className="px-4 py-3 flex items-center gap-3">
              <div className="text-lg font-black text-muted-foreground w-5">{i+1}</div>
              <PixelCat breed={m.b as any} size={36} />
              <div className="flex-1">
                <div className="text-sm font-semibold">{m.n}</div>
                <div className="text-[11px] text-muted-foreground">Resilience {m.s}</div>
              </div>
              <div className="text-sm font-bold text-emerald">RM{m.save}</div>
            </div>
          ))}
        </div>

        {/* Feed */}
        <div className="mt-5 flex justify-between items-center">
          <span className="text-sm font-bold">Community deals</span>
          <button className="text-xs text-ai flex items-center gap-1"><Plus className="w-3 h-3" /> Share</button>
        </div>

        <div className="mt-2 space-y-3">
          {[
            { who: "Sarah", cat: "calico", time: "2m", txt: "Family Mart bundle: 2 onigiri + ayataka tea = RM10. Saved RM4!", up: 24 },
            { who: "Daniel", cat: "tuxedo", time: "1h", txt: "Mid Valley parking RM2 if you exit before 6pm via P5 ✌️", up: 41 },
            { who: "Mei Ling", cat: "siamese", time: "3h", txt: "Tealive 1-for-1 on Mondays with Touch n Go pay. Stack with student ID!", up: 88 },
          ].map((p, i) => (
            <div key={i} className="glass-strong rounded-3xl p-4">
              <div className="flex items-center gap-3">
                <PixelCat breed={p.cat as any} size={36} />
                <div className="flex-1">
                  <div className="text-sm font-semibold">{p.who}</div>
                  <div className="text-[11px] text-muted-foreground">Posted {p.time} ago · Trust 4.9</div>
                </div>
              </div>
              <div className="text-sm mt-3">{p.txt}</div>
              <div className="mt-3 flex items-center gap-3 text-xs">
                <button className="flex items-center gap-1 text-emerald"><ArrowUp className="w-3.5 h-3.5" /> {p.up}</button>
                <button className="flex items-center gap-1 text-muted-foreground"><MessageCircle className="w-3.5 h-3.5" /> Reply</button>
                <span className="ml-auto text-[10px] text-gold font-semibold">+5 XP</span>
              </div>
            </div>
          ))}
        </div>
      </div>
    </MobileFrame>
  );
}
