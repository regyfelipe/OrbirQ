import { HiChevronRight } from 'react-icons/hi'

interface FilterCardProps {
  title: string
  selectedCount: number
  onClick: () => void
}

export default function FilterCard({ title, selectedCount, onClick }: FilterCardProps) {
  return (
    <button
      onClick={onClick}
      className="w-full bg-white border border-gray-300 rounded-lg p-4 flex justify-between items-center hover:border-primary hover:shadow-md transition-all"
    >
      <div className="flex flex-col items-start">
        <span className="text-gray-800 font-medium text-lg">{title}</span>
        <span className="text-sm text-gray-600">
          {selectedCount > 0
            ? `${selectedCount} selecionado(s)`
            : 'Nenhum selecionado'}
        </span>
      </div>
      <HiChevronRight className="text-gray-600 w-5 h-5" />
    </button>
  )
} 