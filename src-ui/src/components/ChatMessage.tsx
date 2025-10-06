import { useState } from 'react'

interface Message {
  type: 'user' | 'assistant'
  text: string
  id: number
}

interface ChatMessageProps {
  message: Message
}

export default function ChatMessage({ message }: ChatMessageProps) {
  const [copied, setCopied] = useState(false)

  const handleCopy = async () => {
    try {
      await navigator.clipboard.writeText(message.text)
      setCopied(true)
      setTimeout(() => setCopied(false), 2000)
    } catch (error) {
      console.error('Failed to copy:', error)
    }
  }

  const isUser = message.type === 'user'

  return (
    <div>
      <div className="flex items-center gap-2 mb-1">
        <span className={`text-sm ${isUser ? 'text-peach' : 'text-sapphire'}`}>
          {isUser ? 'You' : 'Translation'}
        </span>
        <div className="flex-1 h-px bg-surface0"></div>
      </div>
      <div
        onClick={handleCopy}
        className={`relative px-2 py-1 cursor-pointer transition ${
          copied ? 'bg-surface1' : 'hover:bg-surface0'
        }`}
      >
        <div className="whitespace-pre-wrap break-words">{message.text}</div>
        {copied && (
          <span className="text-xs text-green ml-2">📋</span>
        )}
      </div>
    </div>
  )
}
