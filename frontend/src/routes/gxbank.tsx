import { createFileRoute, Link } from "@tanstack/react-router";
import { MobileFrame } from "@/components/MobileFrame";
import { Shield, Zap, PiggyBank, Webhook, Check } from "lucide-react";

export const Route = createFileRoute("/gxbank")({ component: GX });

function GX() {
  return (
    <MobileFrame>
      <div className="px-5 pt-3 pb-6">
        <Link to="/profile" className="text-xs text-muted-foreground">← Back</Link>
        <h1 className="mt-2 text-2xl font-black">GXBank Integration</h1>

        <div className="mt-4 rounded-3xl p-5 bg-grad-emerald text-emerald-foreground relative overflow-hidden">
          <div className="absolute -top-10 -right-10 w-40 h-40 bg-white/20 rounded-full blur-2xl" />
          <div className="relative flex items-center gap-3">
            <div className="w-12 h-12 rounded-2xl bg-white/20 backdrop-blur flex items-center justify-center font-black text-xl">GX</div>
            <div>
              <div className="text-xs opacity-80 uppercase tracking-wider">Connected · Live</div>
              <div className="text-lg font-black">•••• •••• •••• 4392</div>
            </div>
            <Check className="w-6 h-6 ml-auto" />
          </div>
          <div className="mt-4 text-xs opacity-90">Your finances are automatically protected by Mochi 🐱</div>
        </div>

        <div className="mt-4 grid grid-cols-2 gap-3">
          <Vault label="Emergency Vault" value="RM 312.40" rate="+RM 8/wk" />
          <Vault label="Travel Vault" value="RM 145.00" rate="+RM 5/wk" />
        </div>

        <div className="mt-5 text-sm font-bold">Automation</div>
        <div className="mt-2 space-y-2">
          <Feature icon={PiggyBank} title="Round-up savings" desc="Every transaction rounded up to nearest RM and saved." on />
          <Feature icon={Zap} title="AI micro-saving" desc="When risk score spikes, RM5–25 auto-moves to vault." on />
          <Feature icon={Shield} title="Salary auto-allocation" desc="20% of payday → Emergency, 5% → Travel" on />
          <Feature icon={Webhook} title="Webhook automation" desc="Real-time GXBank events → AI engine" on />
        </div>

        <div className="mt-4 glass-strong rounded-3xl p-4">
          <div className="text-xs text-muted-foreground uppercase tracking-wider">This month</div>
          <div className="mt-2 grid grid-cols-3 gap-2">
            <div><div className="text-lg font-black text-emerald">142</div><div className="text-[10px] text-muted-foreground">Auto-saves</div></div>
            <div><div className="text-lg font-black">RM 89</div><div className="text-[10px] text-muted-foreground">Round-ups</div></div>
            <div><div className="text-lg font-black text-ai">11</div><div className="text-[10px] text-muted-foreground">AI moves</div></div>
          </div>
        </div>
      </div>
    </MobileFrame>
  );
}

function Vault({ label, value, rate }: { label: string; value: string; rate: string }) {
  return (
    <div className="glass-strong rounded-3xl p-4">
      <div className="text-[10px] text-muted-foreground uppercase tracking-wider">{label}</div>
      <div className="text-lg font-black mt-1">{value}</div>
      <div className="text-[11px] text-emerald mt-0.5">{rate}</div>
    </div>
  );
}

function Feature({ icon: Icon, title, desc, on }: any) {
  return (
    <div className="glass rounded-2xl p-3 flex items-center gap-3">
      <div className="w-10 h-10 rounded-xl bg-grad-ai flex items-center justify-center"><Icon className="w-4 h-4 text-white" /></div>
      <div className="flex-1">
        <div className="text-sm font-semibold">{title}</div>
        <div className="text-[11px] text-muted-foreground">{desc}</div>
      </div>
      <div className={`w-10 h-6 rounded-full p-0.5 flex ${on ? "bg-emerald justify-end" : "bg-secondary"}`}><div className="w-5 h-5 rounded-full bg-white" /></div>
    </div>
  );
}
