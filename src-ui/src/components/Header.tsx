interface LanguagePair {
  name: string;
  label: string;
  prompt: string;
}

interface HeaderProps {
  onSettingsClick: () => void;
  onClearChat: () => void;
  pairs: LanguagePair[];
  currentIdx: number;
  onSelectPair: (idx: number) => void;
}

export default function Header({
  onSettingsClick,
  onClearChat,
  pairs,
  currentIdx,
  onSelectPair,
}: HeaderProps) {
  return (
    <div className="flex items-center justify-between mb-2 pb-2">
      <div className="flex items-center gap-3">
        <span className="text-sapphire font-bold">🐠 Babelfish</span>
        <div className="flex gap-3">
          {pairs.map((pair, idx) => (
            <button
              key={pair.name}
              onClick={() => onSelectPair(idx)}
              className={`text-sm transition ${
                idx === currentIdx
                  ? "text-yellow font-bold"
                  : "text-overlay0 hover:text-subtext0"
              }`}
            >
              {pair.label}
            </button>
          ))}
        </div>
      </div>
      <div className="flex gap-2 text-overlay0">
        <button
          onClick={onClearChat}
          className="hover:text-text transition text-lg"
          title="Clear chat"
        >
          ⌫
        </button>
        <button
          onClick={onSettingsClick}
          className="hover:text-text transition text-lg"
          title="Settings"
        >
          ⚙
        </button>
      </div>
    </div>
  );
}
