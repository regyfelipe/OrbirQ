'use client'

import { useState, useEffect } from 'react'
import { FaGraduationCap, FaChartLine, FaClock, FaTrophy, FaBook, FaChartBar, FaChartPie } from 'react-icons/fa'
import { Line, Bar, Pie } from 'react-chartjs-2'
import {
  Chart as ChartJS,
  CategoryScale,
  LinearScale,
  PointElement,
  LineElement,
  BarElement,
  ArcElement,
  Title,
  Tooltip,
  Legend,
  Filler
} from 'chart.js'

ChartJS.register(
  CategoryScale,
  LinearScale,
  PointElement,
  LineElement,
  BarElement,
  ArcElement,
  Title,
  Tooltip,
  Legend,
  Filler
)

export default function HomePage() {
  const [selectedPeriod, setSelectedPeriod] = useState('7d')
  const [isLoading, setIsLoading] = useState(true)

  useEffect(() => {
    // Simular carregamento de dados
    setTimeout(() => setIsLoading(false), 1000)
  }, [])

  const progressData = {
    labels: ['Dom', 'Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb'],
    datasets: [
      {
        label: 'Questões Respondidas',
        data: [65, 78, 90, 85, 95, 88, 92],
        fill: true,
        borderColor: '#3B82F6',
        backgroundColor: 'rgba(59, 130, 246, 0.1)',
        tension: 0.4
      }
    ]
  }

  const performanceData = {
    labels: ['Português', 'Matemática', 'História', 'Geografia', 'Física'],
    datasets: [
      {
        label: 'Taxa de Acerto (%)',
        data: [75, 68, 82, 71, 65],
        backgroundColor: [
          'rgba(59, 130, 246, 0.8)',
          'rgba(34, 197, 94, 0.8)',
          'rgba(249, 115, 22, 0.8)',
          'rgba(168, 85, 247, 0.8)',
          'rgba(236, 72, 153, 0.8)'
        ]
      }
    ]
  }

  const distributionData = {
    labels: ['Fácil', 'Médio', 'Difícil'],
    datasets: [
      {
        data: [30, 50, 20],
        backgroundColor: [
          'rgba(34, 197, 94, 0.8)',
          'rgba(249, 115, 22, 0.8)',
          'rgba(239, 68, 68, 0.8)'
        ]
      }
    ]
  }

  if (isLoading) {
    return (
      <div className="min-h-screen bg-gradient-to-br from-gray-50 to-white flex items-center justify-center">
        <div className="animate-spin rounded-full h-16 w-16 border-t-2 border-b-2 border-blue-500"></div>
      </div>
    )
  }

  return (
    <div className="min-h-screen bg-gradient-to-br from-gray-50 to-white p-6">
      <div className="max-w-7xl mx-auto">
        {/* Cabeçalho */}
        <div className="mb-8">
          <h1 className="text-3xl font-bold text-gray-900">Bem-vindo de volta, Usuário!</h1>
          <p className="text-gray-600 mt-2">Confira seu progresso e continue estudando</p>
        </div>

        {/* Cards de Estatísticas */}
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6 mb-8">
          <div className="bg-white rounded-xl p-6 shadow-sm border border-gray-100 hover:shadow-md transition-all duration-200">
            <div className="flex items-center justify-between mb-4">
              <div className="w-12 h-12 bg-blue-100 rounded-lg flex items-center justify-center">
                <FaGraduationCap className="text-blue-500 text-xl" />
              </div>
              <span className="text-sm font-medium text-gray-400">Total</span>
            </div>
            <h3 className="text-2xl font-bold text-gray-900 mb-1">1,248</h3>
            <p className="text-gray-600 text-sm">Questões Respondidas</p>
          </div>

          <div className="bg-white rounded-xl p-6 shadow-sm border border-gray-100 hover:shadow-md transition-all duration-200">
            <div className="flex items-center justify-between mb-4">
              <div className="w-12 h-12 bg-green-100 rounded-lg flex items-center justify-center">
                <FaChartLine className="text-green-500 text-xl" />
              </div>
              <span className="text-sm font-medium text-gray-400">Média</span>
            </div>
            <h3 className="text-2xl font-bold text-gray-900 mb-1">76%</h3>
            <p className="text-gray-600 text-sm">Taxa de Acerto</p>
          </div>

          <div className="bg-white rounded-xl p-6 shadow-sm border border-gray-100 hover:shadow-md transition-all duration-200">
            <div className="flex items-center justify-between mb-4">
              <div className="w-12 h-12 bg-orange-100 rounded-lg flex items-center justify-center">
                <FaClock className="text-orange-500 text-xl" />
              </div>
              <span className="text-sm font-medium text-gray-400">Tempo</span>
            </div>
            <h3 className="text-2xl font-bold text-gray-900 mb-1">2.5h</h3>
            <p className="text-gray-600 text-sm">Tempo de Estudo Hoje</p>
          </div>

          <div className="bg-white rounded-xl p-6 shadow-sm border border-gray-100 hover:shadow-md transition-all duration-200">
            <div className="flex items-center justify-between mb-4">
              <div className="w-12 h-12 bg-purple-100 rounded-lg flex items-center justify-center">
                <FaTrophy className="text-purple-500 text-xl" />
              </div>
              <span className="text-sm font-medium text-gray-400">Ranking</span>
            </div>
            <h3 className="text-2xl font-bold text-gray-900 mb-1">#42</h3>
            <p className="text-gray-600 text-sm">Posição Global</p>
          </div>
        </div>

        {/* Gráficos */}
        <div className="grid grid-cols-1 lg:grid-cols-2 gap-6 mb-8">
          {/* Progresso Semanal */}
          <div className="bg-white rounded-xl p-6 shadow-sm border border-gray-100">
            <div className="flex items-center justify-between mb-6">
              <div className="flex items-center gap-3">
                <FaChartLine className="text-blue-500 text-xl" />
                <h3 className="text-lg font-semibold text-gray-900">Progresso Semanal</h3>
              </div>
              <select
                value={selectedPeriod}
                onChange={(e) => setSelectedPeriod(e.target.value)}
                className="px-3 py-2 border border-gray-200 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-blue-400"
              >
                <option value="7d">Últimos 7 dias</option>
                <option value="14d">Últimos 14 dias</option>
                <option value="30d">Últimos 30 dias</option>
              </select>
            </div>
            <div className="h-64">
              <Line
                data={progressData}
                options={{
                  responsive: true,
                  maintainAspectRatio: false,
                  plugins: {
                    legend: {
                      display: false
                    }
                  },
                  scales: {
                    y: {
                      beginAtZero: true,
                      grid: {
                        display: false
                      }
                    },
                    x: {
                      grid: {
                        display: false
                      }
                    }
                  }
                }}
              />
            </div>
          </div>

          {/* Performance por Disciplina */}
          <div className="bg-white rounded-xl p-6 shadow-sm border border-gray-100">
            <div className="flex items-center gap-3 mb-6">
              <FaChartBar className="text-blue-500 text-xl" />
              <h3 className="text-lg font-semibold text-gray-900">Performance por Disciplina</h3>
            </div>
            <div className="h-64">
              <Bar
                data={performanceData}
                options={{
                  responsive: true,
                  maintainAspectRatio: false,
                  plugins: {
                    legend: {
                      display: false
                    }
                  },
                  scales: {
                    y: {
                      beginAtZero: true,
                      max: 100,
                      grid: {
                        display: false
                      }
                    },
                    x: {
                      grid: {
                        display: false
                      }
                    }
                  }
                }}
              />
            </div>
          </div>
        </div>

        {/* Seção Inferior */}
        <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
          {/* Distribuição de Dificuldade */}
          <div className="bg-white rounded-xl p-6 shadow-sm border border-gray-100">
            <div className="flex items-center gap-3 mb-6">
              <FaChartPie className="text-blue-500 text-xl" />
              <h3 className="text-lg font-semibold text-gray-900">Distribuição de Dificuldade</h3>
            </div>
            <div className="h-64 flex items-center justify-center">
              <div className="w-48">
                <Pie
                  data={distributionData}
                  options={{
                    responsive: true,
                    maintainAspectRatio: false,
                    plugins: {
                      legend: {
                        position: 'bottom'
                      }
                    }
                  }}
                />
              </div>
            </div>
          </div>

          {/* Próximas Metas */}
          <div className="bg-white rounded-xl p-6 shadow-sm border border-gray-100">
            <div className="flex items-center gap-3 mb-6">
              <FaTrophy className="text-blue-500 text-xl" />
              <h3 className="text-lg font-semibold text-gray-900">Próximas Metas</h3>
            </div>
            <div className="space-y-4">
              <div className="flex items-center justify-between">
                <div>
                  <p className="font-medium text-gray-900">Responder 100 questões</p>
                  <p className="text-sm text-gray-500">85/100 completadas</p>
                </div>
                <div className="w-16 h-16 relative">
                  <svg className="w-full h-full" viewBox="0 0 36 36">
                    <path
                      d="M18 2.0845
                        a 15.9155 15.9155 0 0 1 0 31.831
                        a 15.9155 15.9155 0 0 1 0 -31.831"
                      fill="none"
                      stroke="#E5E7EB"
                      strokeWidth="3"
                    />
                    <path
                      d="M18 2.0845
                        a 15.9155 15.9155 0 0 1 0 31.831
                        a 15.9155 15.9155 0 0 1 0 -31.831"
                      fill="none"
                      stroke="#3B82F6"
                      strokeWidth="3"
                      strokeDasharray={`${85 * 1}, 100`}
                      strokeLinecap="round"
                    />
                  </svg>
                  <span className="absolute top-1/2 left-1/2 transform -translate-x-1/2 -translate-y-1/2 text-sm font-medium">
                    85%
                  </span>
                </div>
              </div>
              <div className="flex items-center justify-between">
                <div>
                  <p className="font-medium text-gray-900">Manter 70% de acertos</p>
                  <p className="text-sm text-gray-500">76% atual</p>
                </div>
                <div className="w-16 h-16 relative">
                  <svg className="w-full h-full" viewBox="0 0 36 36">
                    <path
                      d="M18 2.0845
                        a 15.9155 15.9155 0 0 1 0 31.831
                        a 15.9155 15.9155 0 0 1 0 -31.831"
                      fill="none"
                      stroke="#E5E7EB"
                      strokeWidth="3"
                    />
                    <path
                      d="M18 2.0845
                        a 15.9155 15.9155 0 0 1 0 31.831
                        a 15.9155 15.9155 0 0 1 0 -31.831"
                      fill="none"
                      stroke="#3B82F6"
                      strokeWidth="3"
                      strokeDasharray={`${76 * 1}, 100`}
                      strokeLinecap="round"
                    />
                  </svg>
                  <span className="absolute top-1/2 left-1/2 transform -translate-x-1/2 -translate-y-1/2 text-sm font-medium">
                    76%
                  </span>
                </div>
              </div>
            </div>
          </div>

          {/* Últimas Atividades */}
          <div className="bg-white rounded-xl p-6 shadow-sm border border-gray-100">
            <div className="flex items-center gap-3 mb-6">
              <FaBook className="text-blue-500 text-xl" />
              <h3 className="text-lg font-semibold text-gray-900">Últimas Atividades</h3>
            </div>
            <div className="space-y-4">
              <div className="flex items-start gap-4">
                <div className="w-8 h-8 bg-blue-100 rounded-lg flex items-center justify-center flex-shrink-0">
                  <FaBook className="text-blue-500" />
                </div>
                <div>
                  <p className="font-medium text-gray-900">Questão de Português</p>
                  <p className="text-sm text-gray-500">Respondida há 5 minutos</p>
                </div>
              </div>
              <div className="flex items-start gap-4">
                <div className="w-8 h-8 bg-green-100 rounded-lg flex items-center justify-center flex-shrink-0">
                  <FaBook className="text-green-500" />
                </div>
                <div>
                  <p className="font-medium text-gray-900">Questão de Matemática</p>
                  <p className="text-sm text-gray-500">Respondida há 15 minutos</p>
                </div>
              </div>
              <div className="flex items-start gap-4">
                <div className="w-8 h-8 bg-orange-100 rounded-lg flex items-center justify-center flex-shrink-0">
                  <FaBook className="text-orange-500" />
                </div>
                <div>
                  <p className="font-medium text-gray-900">Questão de História</p>
                  <p className="text-sm text-gray-500">Respondida há 30 minutos</p>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  )
}
