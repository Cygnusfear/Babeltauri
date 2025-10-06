import { useState, type KeyboardEvent } from 'react'

interface InputBoxProps {
  onSubmit: (text: string) => void
  disabled: boolean
}

export default function InputBox({ onSubmit, disabled }: InputBoxProps) {
  const [input, setInput] = useState('')

  const handleSubmit = () => {
    if (!input.trim() || disabled) return
    onSubmit(input)
    setInput('')
  }

  const handleKeyDown = (e: KeyboardEvent<HTMLTextAreaElement>) => {
    if (e.key === 'Enter' && !e.shiftKey) {
      e.preventDefault()
      handleSubmit()
    }
  }

  return (
    <div className="border-t border-surface0 pt-3">
      <div className="flex gap-2 items-start mb-2">
        <span className={`${input ? 'text-sapphire' : 'text-overlay0'} select-none`}>│</span>
        <textarea
          value={input}
          onChange={(e) => setInput(e.target.value)}
          onKeyDown={handleKeyDown}
          disabled={disabled}
          placeholder="Type your text here..."
          className="flex-1 bg-transparent text-text placeholder-overlay0 resize-none focus:outline-none border-none"
          rows={3}
          autoFocus
        />
      </div>
    </div>
  )
}
