'use client'

import { useEffect, useState } from 'react'
import { FaSearch, FaComment, FaLightbulb, FaCheck, FaTimes, FaBook, FaChartBar, FaPen, FaExclamationTriangle, FaVideo, FaBookmark, FaRegBookmark, FaFilter } from 'react-icons/fa'
import { useRouter } from 'next/navigation'
import { QuestoesService } from '@/services/questoes.service'
import { Filter, Question } from '@/lib/supabase'

interface Filtros {
  disciplina: string[]
  banca: string[]
  ano: string[]
  termo?: string
  cargo?: string
  assunto?: string
  instituicao?: string
  regiao?: string
  areaAtuacao?: string
  modalidade?: string
  dificuldade?: string
}

interface QuestaoEstado {
  id: string
  respostaSelecionada?: string
  mostrarExplicacao: boolean
  mostrarComentarios: boolean
  mostrarGabarito: boolean
  mostrarAulas: boolean
  mostrarEstatisticas: boolean
  mostrarCadernos: boolean
  mostrarAnotacoes: boolean
  mostrarNotificarErro: boolean
  estaCorreta?: boolean
  anotacao?: string
  salvoEmCaderno: boolean
}

interface Estatisticas {
  totalRespostas: number
  percentualAcertos: number
  distribuicaoRespostas: { [alternativa: string]: number }
}

interface Aula {
  id: string
  titulo: string
  duracao: string
  professor: string
  url: string
}

export default function QuestionsPage() {
  const router = useRouter()
  const [loading, setLoading] = useState(true)
  const [questions, setQuestions] = useState<Question[]>([])
  const [disciplines, setDisciplines] = useState<string[]>([])
  const [banks, setBanks] = useState<string[]>([])
  const [years, setYears] = useState<string[]>([])
  const [showFilters, setShowFilters] = useState(false)
  const [filtros, setFiltros] = useState<Filter>({
    discipline: '',
    bank: '',
    year: undefined,
    search: ''
  })
  const [totalQuestoes, setTotalQuestoes] = useState(0)
  const [disciplinaSelecionada, setDisciplinaSelecionada] = useState('')
  const [showDisciplinas, setShowDisciplinas] = useState(false)
  const [estadoQuestoes, setEstadoQuestoes] = useState<{ [key: string]: QuestaoEstado }>({})
  const [comentarios, setComentarios] = useState<{ [key: string]: string[] }>({})
  const [estatisticas, setEstatisticas] = useState<{ [key: string]: Estatisticas }>({})
  const [aulas, setAulas] = useState<{ [key: string]: Aula[] }>({})
  const [cadernos, setCadernos] = useState<string[]>(['Favoritos', 'Para Revisar', 'Erradas'])

  useEffect(() => {
    carregarFiltros()
    carregarQuestoes()
    setEstatisticas({
      'exemplo-id': {
        totalRespostas: 1234,
        percentualAcertos: 65,
        distribuicaoRespostas: {
          'A': 25,
          'B': 15,
          'C': 45,
          'D': 10,
          'E': 5
        }
      }
    })
    setAulas({
      'exemplo-id': [
        {
          id: '1',
          titulo: 'Conceitos Básicos',
          duracao: '15:30',
          professor: 'Prof. Silva',
          url: '#'
        },
        {
          id: '2',
          titulo: 'Resolução Detalhada',
          duracao: '20:45',
          professor: 'Prof. Santos',
          url: '#'
        }
      ]
    })
  }, [])

  const carregarFiltros = async () => {
    try {
      const { disciplines, banks, years } = await QuestoesService.carregarFiltros()
      setDisciplines(disciplines)
      setBanks(banks)
      setYears(years)
    } catch (error) {
      console.error('Erro ao carregar filtros:', error)
    }
  }

  const carregarQuestoes = async () => {
    setLoading(true)
    try {
      const questoes = await QuestoesService.carregarQuestoes(filtros)
      setQuestions(questoes)
      setTotalQuestoes(questoes.length)
    } catch (error) {
      console.error('Erro ao carregar questões:', error)
    }
    setLoading(false)
  }

  const handleSearch = (e: React.FormEvent) => {
    e.preventDefault()
    carregarQuestoes()
  }

  const handleResolverQuestao = (questionId: number) => {
    router.push(`/questions/${questionId}`)
  }

  const selecionarResposta = (questaoId: string, alternativa: string) => {
    setEstadoQuestoes(prev => ({
      ...prev,
      [questaoId]: {
        ...prev[questaoId],
        respostaSelecionada: alternativa,
        estaCorreta: alternativa === questions.find(q => q.id === questaoId)?.resposta
      }
    }))
  }

  const toggleExplicacao = (questaoId: string) => {
    setEstadoQuestoes(prev => ({
      ...prev,
      [questaoId]: {
        ...prev[questaoId],
        mostrarExplicacao: !prev[questaoId]?.mostrarExplicacao
      }
    }))
  }

  const toggleComentarios = (questaoId: string) => {
    setEstadoQuestoes(prev => ({
      ...prev,
      [questaoId]: {
        ...prev[questaoId],
        mostrarComentarios: !prev[questaoId]?.mostrarComentarios
      }
    }))
  }

  const adicionarComentario = (questaoId: string, comentario: string) => {
    setComentarios(prev => ({
      ...prev,
      [questaoId]: [...(prev[questaoId] || []), comentario]
    }))
  }

  const toggleGabarito = (questaoId: string) => {
    setEstadoQuestoes(prev => ({
      ...prev,
      [questaoId]: {
        ...prev[questaoId],
        mostrarGabarito: !prev[questaoId]?.mostrarGabarito
      }
    }))
  }

  const toggleAulas = (questaoId: string) => {
    setEstadoQuestoes(prev => ({
      ...prev,
      [questaoId]: {
        ...prev[questaoId],
        mostrarAulas: !prev[questaoId]?.mostrarAulas
      }
    }))
  }

  const toggleEstatisticas = (questaoId: string) => {
    setEstadoQuestoes(prev => ({
      ...prev,
      [questaoId]: {
        ...prev[questaoId],
        mostrarEstatisticas: !prev[questaoId]?.mostrarEstatisticas
      }
    }))
  }

  const toggleCadernos = (questaoId: string) => {
    setEstadoQuestoes(prev => ({
      ...prev,
      [questaoId]: {
        ...prev[questaoId],
        mostrarCadernos: !prev[questaoId]?.mostrarCadernos
      }
    }))
  }

  const toggleAnotacoes = (questaoId: string) => {
    setEstadoQuestoes(prev => ({
      ...prev,
      [questaoId]: {
        ...prev[questaoId],
        mostrarAnotacoes: !prev[questaoId]?.mostrarAnotacoes
      }
    }))
  }

  const toggleNotificarErro = (questaoId: string) => {
    setEstadoQuestoes(prev => ({
      ...prev,
      [questaoId]: {
        ...prev[questaoId],
        mostrarNotificarErro: !prev[questaoId]?.mostrarNotificarErro
      }
    }))
  }

  const salvarAnotacao = (questaoId: string, texto: string) => {
    setEstadoQuestoes(prev => ({
      ...prev,
      [questaoId]: {
        ...prev[questaoId],
        anotacao: texto
      }
    }))
  }

  const toggleSalvarEmCaderno = (questaoId: string) => {
    setEstadoQuestoes(prev => ({
      ...prev,
      [questaoId]: {
        ...prev[questaoId],
        salvoEmCaderno: !prev[questaoId]?.salvoEmCaderno
      }
    }))
  }

  const notificarErro = (questaoId: string, descricao: string) => {
    console.log(`Erro reportado para questão ${questaoId}:`, descricao)
    alert('Erro reportado com sucesso! Agradecemos sua contribuição.')
    toggleNotificarErro(questaoId)
  }

  return (
    <div className="min-h-screen bg-gray-50">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        {/* Cabeçalho */}
        <div className="mb-8">
          <h1 className="text-3xl font-bold text-gray-900">Questões</h1>
          <p className="mt-2 text-sm text-gray-600">
            Explore nossa base de questões e pratique para suas provas
          </p>
        </div>

        {/* Barra de pesquisa e filtros */}
        <div className="bg-white rounded-lg shadow-sm p-4 mb-6">
          <form onSubmit={handleSearch} className="flex gap-4 mb-4">
            <div className="flex-1 relative">
              <input
                type="text"
                placeholder="Pesquisar questões..."
                className="w-full pl-10 pr-4 py-3 border rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500"
                value={filtros.search}
                onChange={(e) => setFiltros({ ...filtros, search: e.target.value })}
              />
              <FaSearch className="absolute left-3 top-1/2 -translate-y-1/2 text-gray-400" />
            </div>
            <button
              type="button"
              onClick={() => setShowFilters(!showFilters)}
              className="px-6 py-3 bg-gray-100 rounded-lg hover:bg-gray-200 flex items-center gap-2 font-medium"
            >
              <FaFilter />
              Filtros
            </button>
          </form>

          {showFilters && (
            <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
              <select
                value={filtros.discipline}
                onChange={(e) => setFiltros({ ...filtros, discipline: e.target.value })}
                className="w-full px-4 py-2.5 border rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500 bg-white"
              >
                <option value="">Todas as disciplinas</option>
                {disciplines.map((discipline) => (
                  <option key={discipline} value={discipline}>
                    {discipline}
                  </option>
                ))}
              </select>

              <select
                value={filtros.bank}
                onChange={(e) => setFiltros({ ...filtros, bank: e.target.value })}
                className="w-full px-4 py-2.5 border rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500 bg-white"
              >
                <option value="">Todas as bancas</option>
                {banks.map((bank) => (
                  <option key={bank} value={bank}>
                    {bank}
                  </option>
                ))}
              </select>

              <select
                value={filtros.year?.toString() || ''}
                onChange={(e) => setFiltros({ ...filtros, year: e.target.value ? parseInt(e.target.value) : undefined })}
                className="w-full px-4 py-2.5 border rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500 bg-white"
              >
                <option value="">Todos os anos</option>
                {years.map((year) => (
                  <option key={year} value={year}>
                    {year}
                  </option>
                ))}
              </select>
            </div>
          )}
        </div>

        {/* Total de Questões */}
        <div className="text-gray-600 mb-4">
          Foram encontradas <span className="font-medium text-gray-900">{totalQuestoes.toLocaleString()}</span> questões
        </div>

        {/* Lista de Questões */}
        {loading ? (
          <div className="flex justify-center items-center h-64">
            <div className="animate-spin rounded-full h-12 w-12 border-t-2 border-b-2 border-blue-500"></div>
          </div>
        ) : questions.length > 0 ? (
          <div className="grid gap-4">
            {questions.map((question) => (
              <div key={question.id} className="bg-white rounded-lg shadow-sm p-6 hover:shadow-md transition-shadow">
                <div className="flex items-center gap-4 text-sm text-gray-500 mb-4">
                  <span className="px-3 py-1 bg-gray-100 rounded-full">{question.discipline}</span>
                  <span className="px-3 py-1 bg-gray-100 rounded-full">{question.bank}</span>
                  <span className="px-3 py-1 bg-gray-100 rounded-full">{question.year}</span>
                </div>
                <div className="prose max-w-none mb-4" dangerouslySetInnerHTML={{ __html: question.content }} />
                <div className="flex justify-between items-center">
                  <button
                    onClick={() => handleResolverQuestao(question.id)}
                    className="px-6 py-2.5 bg-blue-500 text-white rounded-lg hover:bg-blue-600 transition-colors font-medium"
                  >
                    Resolver Questão
                  </button>
                  <div className="flex items-center gap-4 text-sm text-gray-500">
                    {question.statistics && (
                      <>
                        <span>{question.statistics.total_answers} respostas</span>
                        <span>{Math.round((question.statistics.correct_answers / question.statistics.total_answers) * 100)}% de acerto</span>
                      </>
                    )}
                  </div>
                </div>
              </div>
            ))}
          </div>
        ) : (
          <div className="text-center py-12">
            <div className="text-gray-400 text-lg mb-2">Nenhuma questão encontrada</div>
            <p className="text-gray-500">Tente ajustar seus filtros de busca</p>
          </div>
        )}
      </div>
    </div>
  )
}