import { useState, useEffect, useRef } from "react";
import { invoke } from "@tauri-apps/api/core";
import ChatMessage from "./components/ChatMessage";
import InputBox from "./components/InputBox";
import Header from "./components/Header";

interface LanguagePair {
  name: string;
  label: string;
  prompt: string;
}

interface Message {
  type: "user" | "assistant";
  text: string;
  id: number;
}

function App() {
  const [pairs, setPairs] = useState<LanguagePair[]>([]);
  const [currentPairIdx, setCurrentPairIdx] = useState(0);
  const [messages, setMessages] = useState<Message[]>([]);
  const [isTranslating, setIsTranslating] = useState(false);
  const [apiKey, setApiKey] = useState("");
  const [showSettings, setShowSettings] = useState(false);
  const messagesEndRef = useRef<HTMLDivElement>(null);
  const [messageIdCounter, setMessageIdCounter] = useState(0);

  useEffect(() => {
    loadPairs();
    loadApiKey();
  }, []);

  useEffect(() => {
    messagesEndRef.current?.scrollIntoView({ behavior: "smooth" });
  }, [messages]);

  const loadPairs = async () => {
    try {
      const languagePairs = await invoke<LanguagePair[]>("get_language_pairs");
      setPairs(languagePairs);
    } catch (error) {
      console.error("Failed to load language pairs:", error);
    }
  };

  const loadApiKey = async () => {
    try {
      const key = await invoke<string>("get_api_key");
      setApiKey(key);
      if (!key) {
        setShowSettings(true);
      }
    } catch (error) {
      console.error("Failed to load API key:", error);
    }
  };

  const handleTranslate = async (text: string) => {
    if (!text.trim() || isTranslating || !pairs[currentPairIdx]) return;

    const userMsg: Message = { type: "user", text, id: messageIdCounter };
    setMessageIdCounter((prev) => prev + 1);
    setMessages((prev) => [...prev, userMsg]);
    setIsTranslating(true);

    try {
      const translation = await invoke<string>("translate", {
        pairName: pairs[currentPairIdx].name,
        text,
      });
      const assistantMsg: Message = {
        type: "assistant",
        text: translation,
        id: messageIdCounter + 1,
      };
      setMessageIdCounter((prev) => prev + 1);
      setMessages((prev) => [...prev, assistantMsg]);
    } catch (error) {
      const errorMsg: Message = {
        type: "assistant",
        text: `Error: ${error}`,
        id: messageIdCounter + 1,
      };
      setMessageIdCounter((prev) => prev + 1);
      setMessages((prev) => [...prev, errorMsg]);
    } finally {
      setIsTranslating(false);
    }
  };

  const handleSaveApiKey = async (key: string) => {
    try {
      await invoke("set_api_key", { key });
      setApiKey(key);
      setShowSettings(false);
    } catch (error) {
      console.error("Failed to save API key:", error);
    }
  };

  const handleClearChat = () => {
    setMessages([]);
  };

  return (
    <div className="flex flex-col h-screen bg-base text-text p-3">
      <Header
        onSettingsClick={() => setShowSettings(true)}
        onClearChat={handleClearChat}
        pairs={pairs}
        currentIdx={currentPairIdx}
        onSelectPair={setCurrentPairIdx}
      />

      <div className="flex-1 overflow-y-auto space-y-3 mb-3">
        {messages.map((msg) => (
          <ChatMessage key={msg.id} message={msg} />
        ))}
        {isTranslating && (
          <div className="flex items-center gap-2">
            <span className="text-sm text-sapphire">Translation</span>
            <div className="flex-1 h-px bg-surface0"></div>
          </div>
        )}
        <div ref={messagesEndRef} />
      </div>

      <InputBox
        onSubmit={handleTranslate}
        disabled={isTranslating || !apiKey}
      />

      {showSettings && (
        <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
          <div className="bg-mantle rounded-lg p-6 w-96 border border-surface0">
            <h2 className="text-xl font-bold mb-4 text-text">Settings</h2>
            <label className="block mb-2 text-sm text-subtext1">OpenRouter API Key</label>
            <input
              type="password"
              className="w-full px-3 py-2 bg-surface0 text-text placeholder-overlay0 rounded border border-surface1 focus:outline-none focus:border-blue mb-4"
              value={apiKey}
              onChange={(e) => setApiKey(e.target.value)}
              placeholder="sk-or-..."
            />
            <div className="flex gap-2">
              <button
                onClick={() => handleSaveApiKey(apiKey)}
                className="flex-1 bg-blue hover:bg-sapphire px-4 py-2 rounded transition text-base"
              >
                Save
              </button>
              <button
                onClick={() => setShowSettings(false)}
                className="flex-1 bg-surface0 hover:bg-surface1 px-4 py-2 rounded transition text-text"
              >
                Cancel
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}

export default App;
