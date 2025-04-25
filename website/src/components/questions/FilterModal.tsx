import { HiX, HiCheck } from 'react-icons/hi'

interface FilterModalProps {
  title: string
  options: string[]
  selectedOptions: string[]
  onClose: () => void
  onToggleOption: (option: string) => void
  onApply: () => void
}

export default function FilterModal({
  title,
  options,
  selectedOptions,
  onClose,
  onToggleOption,
  onApply,
}: FilterModalProps) {
  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center bg-black bg-opacity-75">
      <div className="bg-gray-900 w-full max-w-md rounded-lg shadow-xl border border-gray-800">
        {/* Header */}
        <div className="flex items-center justify-between p-4 border-b border-gray-800">
          <h2 className="text-lg font-medium text-white">{title}</h2>
          <button
            onClick={onClose}
            className="p-1 rounded-full hover:bg-gray-800 transition-colors"
          >
            <HiX className="w-5 h-5 text-gray-400" />
          </button>
        </div>

        {/* Options */}
        <div className="p-4 max-h-[60vh] overflow-y-auto">
          <div className="space-y-1">
            {options.map((option) => (
              <button
                key={option}
                onClick={() => onToggleOption(option)}
                className="w-full px-3 py-2 flex items-center justify-between hover:bg-gray-800 rounded transition-colors"
              >
                <span className="text-white">{option}</span>
                <div className={`w-5 h-5 rounded border flex items-center justify-center ${
                  selectedOptions.includes(option)
                    ? 'border-primary bg-primary'
                    : 'border-gray-600'
                }`}>
                  {selectedOptions.includes(option) && (
                    <HiCheck className="w-4 h-4 text-white" />
                  )}
                </div>
              </button>
            ))}
          </div>
        </div>

        {/* Footer */}
        <div className="p-4 border-t border-gray-800 flex justify-end gap-3">
          <button
            onClick={onClose}
            className="px-4 py-2 text-gray-400 hover:bg-gray-800 rounded transition-colors"
          >
            Cancelar
          </button>
          <button
            onClick={onApply}
            className="px-4 py-2 bg-primary text-white font-medium rounded hover:bg-primary-dark transition-colors"
          >
            Aplicar
          </button>
        </div>
      </div>
    </div>
  )
} 