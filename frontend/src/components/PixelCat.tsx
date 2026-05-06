// Pixel cat avatar rendered via CSS grid (16x16) — no external assets.
type Breed = "orange-tabby" | "british-shorthair" | "siamese" | "persian" | "calico" | "tuxedo" | "ragdoll";

const palettes: Record<Breed, { body: string; belly: string; ears: string; stripe?: string }> = {
  "orange-tabby": { body: "#f59e42", belly: "#fde7c8", ears: "#d97706", stripe: "#b45309" },
  "british-shorthair": { body: "#9aa6b2", belly: "#d6dde6", ears: "#6b7480" },
  siamese: { body: "#f3e7d3", belly: "#fff7e6", ears: "#5b3a29", stripe: "#5b3a29" },
  persian: { body: "#fafafa", belly: "#ffffff", ears: "#e5e7eb" },
  calico: { body: "#fff7e6", belly: "#fde7c8", ears: "#1f2937", stripe: "#f59e42" },
  tuxedo: { body: "#0f172a", belly: "#ffffff", ears: "#0f172a" },
  ragdoll: { body: "#ede0d4", belly: "#ffffff", ears: "#7c5e4a", stripe: "#7c5e4a" },
};

// 16x16 grid: 0=transparent, 1=body, 2=belly, 3=ears, 4=stripe, 5=eye, 6=cheek, 7=mouth
const SPRITE = [
  "0000000000000000",
  "0003000000003000",
  "0033300000033300",
  "0333330000333330",
  "0331330000331330",
  "0011111111111100",
  "0114411111144110",
  "0111551111551110",
  "0111111771111110",
  "0111166666611110",
  "0112222222221110",
  "0122222222222210",
  "0122222222222210",
  "0112222222221100",
  "0011222222211100",
  "0001100000110000",
];

export function PixelCat({ breed = "orange-tabby", size = 160, hat, glasses }: { breed?: Breed; size?: number; hat?: "crown" | "cap" | null; glasses?: boolean }) {
  const p = palettes[breed];
  const map: Record<string, string> = {
    "0": "transparent", "1": p.body, "2": p.belly, "3": p.ears, "4": p.stripe ?? p.ears,
    "5": "#0f172a", "6": "#f9a8d4", "7": "#7c2d12",
  };
  const cell = size / 16;
  return (
    <div className="relative inline-block pixelated select-none" style={{ width: size, height: size }}>
      <div className="grid" style={{ gridTemplateColumns: `repeat(16, ${cell}px)`, gridTemplateRows: `repeat(16, ${cell}px)` }}>
        {SPRITE.flatMap((row, y) => row.split("").map((c, x) => (
          <div key={`${x}-${y}`} style={{ background: map[c], width: cell, height: cell }} />
        )))}
      </div>
      {hat === "crown" && (
        <div className="absolute" style={{ top: -cell * 1.5, left: cell * 4, width: cell * 8, height: cell * 2.5 }}>
          <div className="w-full h-full bg-grad-gold" style={{ clipPath: "polygon(0 100%, 15% 30%, 30% 70%, 50% 0%, 70% 70%, 85% 30%, 100% 100%)" }} />
        </div>
      )}
      {hat === "cap" && (
        <div className="absolute rounded-t-md bg-emerald" style={{ top: 0, left: cell * 3, width: cell * 10, height: cell * 2 }} />
      )}
      {glasses && (
        <div className="absolute flex gap-1" style={{ top: cell * 7, left: cell * 4, width: cell * 8 }}>
          <div className="border-2 border-black rounded-full bg-white/20" style={{ width: cell * 3, height: cell * 2 }} />
          <div className="border-2 border-black rounded-full bg-white/20" style={{ width: cell * 3, height: cell * 2 }} />
        </div>
      )}
    </div>
  );
}

export const CAT_BREEDS: { id: Breed; name: string }[] = [
  { id: "orange-tabby", name: "Orange Tabby" },
  { id: "british-shorthair", name: "British Shorthair" },
  { id: "siamese", name: "Siamese" },
  { id: "persian", name: "Persian" },
  { id: "calico", name: "Calico" },
  { id: "tuxedo", name: "Tuxedo" },
  { id: "ragdoll", name: "Ragdoll" },
];
