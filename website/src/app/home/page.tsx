'use client'

import { useState, useEffect } from 'react'
import Image from 'next/image'
import Link from 'next/link'
import { useRouter, usePathname } from 'next/navigation'
import { authService } from '@/services/auth.service'
import { HiHome, HiBookmark, HiDocument, HiClock, HiUserGroup, HiHeart, HiFolder, HiAcademicCap, HiChartBar, HiLightningBolt } from 'react-icons/hi'

interface Activity {
  id: string
  title: string
  subtitle: string
  score: number
  type: 'simulado' | 'questoes' | 'revisao' | 'video' | 'resumo' | 'lista' | 'prova'
}

interface Exam {
  id: string
  title: string
  date: Date
  subjects: string[]
}

interface NavigationItem {
  icon: React.ElementType
  label: string
  href: string
}

interface Achievement {
  id: string
  title: string
  description: string
  icon: React.ElementType
  progress: number
  color: string
}

interface StudyTip {
  id: string
  title: string
  description: string
  icon: React.ElementType
}

export default function HomePage() {
  const router = useRouter()
  const pathname = usePathname()
  const [showNotifications, setShowNotifications] = useState(false)
  const [userName, setUserName] = useState<string>('')
  const [userType, setUserType] = useState<'aluno' | 'professor'>('aluno')
  const [showSidebar, setShowSidebar] = useState(false)
  const [selectedSubject, setSelectedSubject] = useState<string>('all')

  const navigationItems: NavigationItem[] = [
    { icon: HiHome, label: 'Home', href: '/home' },
    { icon: HiBookmark, label: 'Questões', href: '/questions' },
    { icon: HiDocument, label: 'Provas', href: '/exams' },
    { icon: HiClock, label: 'Simulados', href: '/simulated' },
    { icon: HiUserGroup, label: 'Grupo', href: '/group' },
    { icon: HiHeart, label: 'Pasta', href: '/folder' },
  ]

  const achievements: Achievement[] = [
    {
      id: '1',
      title: 'Mestre das Questões',
      description: 'Responda 1000 questões',
      icon: HiAcademicCap,
      progress: 65,
      color: 'blue'
    },
    {
      id: '2',
      title: 'Velocista',
      description: 'Complete 5 simulados em tempo recorde',
      icon: HiLightningBolt,
      progress: 40,
      color: 'yellow'
    },
    {
      id: '3',
      title: 'Nota Máxima',
      description: 'Alcance 100% em 3 provas seguidas',
      icon: HiChartBar,
      progress: 85,
      color: 'green'
    }
  ]

  const studyTips: StudyTip[] = [
    {
      id: '1',
      title: 'Melhor horário para estudar',
      description: 'Baseado no seu histórico, você tem melhor desempenho estudando pela manhã.',
      icon: HiClock
    },
    {
      id: '2',
      title: 'Matérias para revisar',
      description: 'Recomendamos revisar Matemática e Física esta semana.',
      icon: HiBookmark
    }
  ]

  const subjects = [
    'Todas', 'Matemática', 'Física', 'Química', 'Biologia', 'História', 'Geografia'
  ]

  const [activities] = useState<Activity[]>([
    {
      id: '1',
      title: 'Simulado ENEM 2024',
      subtitle: 'Matemática e Física',
      score: 85,
      type: 'simulado'
    },
    {
      id: '2',
      title: 'Lista de Exercícios',
      subtitle: 'Química Orgânica',
      score: 92,
      type: 'lista'
    },
    {
      id: '3',
      title: 'Revisão do Edital',
      subtitle: 'Direito Constitucional',
      score: 78,
      type: 'revisao'
    }
  ])

  const [upcomingExams] = useState<Exam[]>([
    {
      id: '1',
      title: 'Prova de Matemática',
      date: new Date('2024-05-15T14:00:00'),
      subjects: ['Álgebra', 'Geometria', 'Trigonometria']
    },
    {
      id: '2',
      title: 'Avaliação de Física',
      date: new Date('2024-05-20T10:00:00'),
      subjects: ['Mecânica', 'Termodinâmica']
    }
  ])

  const stats = {
    questionsAnswered: 248,
    examsCompleted: 12
  }

  useEffect(() => {
    const checkAuth = async () => {
      const isAuthenticated = await authService.checkCurrentSession()
      if (!isAuthenticated) {
        router.push('/login')
        return
      }
      
      if (authService.currentUser) {
        setUserName(authService.currentUser.name)
        setUserType(authService.currentUser.user_type)
      }
    }

    checkAuth()
  }, [router])

  const handleLogout = async () => {
    await authService.logout()
    router.push('/login')
  }

  const getProgressColor = (progress: number) => {
    if (progress >= 80) return 'bg-green-500'
    if (progress >= 50) return 'bg-yellow-500'
    return 'bg-blue-500'
  }

  return (
    <div className="min-h-screen bg-gray-100 flex">
      {/* Sidebar */}
      <aside className={`fixed lg:static inset-y-0 left-0 z-50 w-64 bg-white transform ${showSidebar ? 'translate-x-0' : '-translate-x-full'} lg:translate-x-0 transition-transform duration-300 ease-in-out shadow-lg`}>
        <div className="h-full flex flex-col">
          <div className="p-4 border-b">
            <div className="flex items-center space-x-4">
              <Image
                src="/logo_txt.png"
                alt="Orbirq Logo"
                width={40}
                height={40}
                className="rounded-full bg-white p-1"
              />
              <div>
                <h2 className="font-semibold text-gray-800">{userName}</h2>
                <p className="text-sm text-gray-500 capitalize">{userType}</p>
              </div>
            </div>
          </div>

          <nav className="flex-1 p-4 space-y-1">
            {navigationItems.map((item) => (
              <Link
                key={item.href}
                href={item.href}
                className={`flex items-center space-x-3 px-4 py-3 rounded-lg transition-colors ${
                  pathname === item.href
                    ? 'bg-blue-50 text-blue-600'
                    : 'text-gray-600 hover:bg-gray-50'
                }`}
              >
                <item.icon className="w-5 h-5" />
                <span>{item.label}</span>
              </Link>
            ))}
          </nav>

          <div className="p-4 border-t">
            <button
              onClick={handleLogout}
              className="flex items-center space-x-3 px-4 py-3 w-full text-left text-red-600 hover:bg-red-50 rounded-lg transition-colors"
            >
              <svg xmlns="http://www.w3.org/2000/svg" className="h-5 w-5" viewBox="0 0 20 20" fill="currentColor">
                <path fillRule="evenodd" d="M3 3a1 1 0 00-1 1v12a1 1 0 001 1h12a1 1 0 001-1V4a1 1 0 00-1-1H3zm11 3a1 1 0 11-2 0 1 1 0 012 0zm-8.707.293a1 1 0 011.414 0L10 9.586l3.293-3.293a1 1 0 111.414 1.414l-4 4a1 1 0 01-1.414 0l-4-4a1 1 0 010-1.414z" clipRule="evenodd" />
              </svg>
              <span>Sair</span>
            </button>
          </div>
        </div>
      </aside>

      {/* Conteúdo Principal */}
      <div className="flex-1">
        {/* Header Mobile */}
        <header className="bg-blue-600 text-white lg:hidden">
          <div className="container mx-auto px-4 py-4">
            <div className="flex justify-between items-center">
              <button
                onClick={() => setShowSidebar(!showSidebar)}
                className="p-2 hover:bg-blue-700 rounded-lg transition-colors"
              >
                <svg xmlns="http://www.w3.org/2000/svg" className="h-6 w-6" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M4 6h16M4 12h16M4 18h16" />
                </svg>
              </button>
              <button
                onClick={() => setShowNotifications(true)}
                className="p-2 hover:bg-blue-700 rounded-lg transition-colors"
              >
                <svg xmlns="http://www.w3.org/2000/svg" className="h-6 w-6" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M15 17h5l-1.405-1.405A2.032 2.032 0 0118 14.158V11a6.002 6.002 0 00-4-5.659V5a2 2 0 10-4 0v.341C7.67 6.165 6 8.388 6 11v3.159c0 .538-.214 1.055-.595 1.436L4 17h5m6 0v1a3 3 0 11-6 0v-1m6 0H9" />
                </svg>
              </button>
            </div>
          </div>
        </header>

        <main className="container mx-auto px-4 py-8">
          {/* Boas-vindas e Filtro de Matérias */}
          <div className="mb-8">
            <h2 className="text-3xl font-bold mb-4">Bem-vindo, {userName}!</h2>
            <div className="flex flex-wrap gap-2">
              {subjects.map((subject) => (
                <button
                  key={subject}
                  onClick={() => setSelectedSubject(subject.toLowerCase())}
                  className={`px-4 py-2 rounded-full text-sm font-medium transition-colors ${
                    selectedSubject === subject.toLowerCase()
                      ? 'bg-blue-600 text-white'
                      : 'bg-white text-gray-600 hover:bg-gray-50'
                  }`}
                >
                  {subject}
                </button>
              ))}
            </div>
          </div>

          {/* Grid de Estatísticas e Conquistas */}
          <div className="grid grid-cols-1 lg:grid-cols-3 gap-6 mb-8">
            {/* Estatísticas */}
            <div className="lg:col-span-2">
              <h3 className="text-lg font-semibold mb-4">Seu Progresso</h3>
              <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                <div className="bg-white rounded-lg p-6 shadow-sm">
                  <div className="text-blue-600 mb-4">
                    <svg xmlns="http://www.w3.org/2000/svg" className="h-8 w-8" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                      <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 5H7a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2V7a2 2 0 00-2-2h-2M9 5a2 2 0 002 2h2a2 2 0 002-2M9 5a2 2 0 012-2h2a2 2 0 012 2" />
                    </svg>
                  </div>
                  <h3 className="text-3xl font-bold text-blue-600 mb-2">{stats.questionsAnswered}</h3>
                  <p className="text-gray-600">Questões Respondidas</p>
                  <div className="mt-4 bg-gray-200 rounded-full h-2">
                    <div className={getProgressColor(stats.questionsAnswered)} style={{ width: `${stats.questionsAnswered}%` }}></div>
                  </div>
                </div>
                <div className="bg-white rounded-lg p-6 shadow-sm">
                  <div className="text-green-600 mb-4">
                    <svg xmlns="http://www.w3.org/2000/svg" className="h-8 w-8" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                      <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z" />
                    </svg>
                  </div>
                  <h3 className="text-3xl font-bold text-green-600 mb-2">{stats.examsCompleted}</h3>
                  <p className="text-gray-600">Provas Realizadas</p>
                  <div className="mt-4 bg-gray-200 rounded-full h-2">
                    <div className={getProgressColor(stats.examsCompleted)} style={{ width: `${stats.examsCompleted}%` }}></div>
                  </div>
                </div>
              </div>
            </div>

            {/* Conquistas */}
            <div>
              <h3 className="text-lg font-semibold mb-4">Suas Conquistas</h3>
              <div className="bg-white rounded-lg p-6 shadow-sm space-y-4">
                {achievements.map((achievement) => (
                  <div key={achievement.id} className="flex items-start space-x-4">
                    <div className={`p-2 rounded-lg bg-${achievement.color}-100`}>
                      <achievement.icon className={`w-6 h-6 text-${achievement.color}-600`} />
                    </div>
                    <div className="flex-1">
                      <h4 className="font-medium text-gray-900">{achievement.title}</h4>
                      <p className="text-sm text-gray-500">{achievement.description}</p>
                      <div className="mt-2 bg-gray-200 rounded-full h-2">
                        <div
                          className={getProgressColor(achievement.progress)}
                          style={{ width: `${achievement.progress}%` }}
                        ></div>
                      </div>
                    </div>
                  </div>
                ))}
              </div>
            </div>
          </div>

          {/* Dicas de Estudo */}
          {userType === 'aluno' && (
            <section className="mb-8">
              <h3 className="text-lg font-semibold mb-4">Dicas Personalizadas</h3>
              <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                {studyTips.map((tip) => (
                  <div key={tip.id} className="bg-white rounded-lg p-6 shadow-sm">
                    <div className="flex items-start space-x-4">
                      <div className="p-2 rounded-lg bg-blue-100">
                        <tip.icon className="w-6 h-6 text-blue-600" />
                      </div>
                      <div>
                        <h4 className="font-medium text-gray-900">{tip.title}</h4>
                        <p className="text-sm text-gray-500">{tip.description}</p>
                      </div>
                    </div>
                  </div>
                ))}
              </div>
            </section>
          )}

          {/* Seção específica para professores */}
          {userType === 'professor' && (
            <section className="mb-8">
              <h3 className="text-lg font-semibold mb-4">Gestão de Turmas</h3>
              <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
                <div className="bg-white rounded-lg p-6 shadow-sm">
                  <div className="text-purple-600 mb-4">
                    <HiUserGroup className="w-8 h-8" />
                  </div>
                  <h4 className="font-medium text-gray-900">Alunos Ativos</h4>
                  <p className="text-3xl font-bold text-purple-600">156</p>
                </div>
                <div className="bg-white rounded-lg p-6 shadow-sm">
                  <div className="text-orange-600 mb-4">
                    <HiDocument className="w-8 h-8" />
                  </div>
                  <h4 className="font-medium text-gray-900">Provas Criadas</h4>
                  <p className="text-3xl font-bold text-orange-600">24</p>
                </div>
                <div className="bg-white rounded-lg p-6 shadow-sm">
                  <div className="text-green-600 mb-4">
                    <HiChartBar className="w-8 h-8" />
                  </div>
                  <h4 className="font-medium text-gray-900">Média de Desempenho</h4>
                  <p className="text-3xl font-bold text-green-600">78%</p>
                </div>
              </div>
            </section>
          )}

          {/* Atividades Recentes */}
          <section className="mb-8">
            <div className="flex justify-between items-center mb-4">
              <h3 className="text-lg font-semibold">Atividades Recentes</h3>
              <Link href="/activities" className="text-blue-600 hover:text-blue-700">
                Ver todas
              </Link>
            </div>
            <div className="space-y-4">
              {activities.map(activity => (
                <div key={activity.id} className="bg-white rounded-lg p-4 shadow-sm">
                  <div className="flex items-center">
                    <div className="bg-blue-100 rounded-full p-3 mr-4">
                      <svg xmlns="http://www.w3.org/2000/svg" className="h-6 w-6 text-blue-600" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                        <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 5H7a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2V7a2 2 0 00-2-2h-2M9 5a2 2 0 002 2h2a2 2 0 002-2M9 5a2 2 0 012-2h2a2 2 0 012 2" />
                      </svg>
                    </div>
                    <div className="flex-1">
                      <h3 className="font-semibold">{activity.title}</h3>
                      <p className="text-gray-600 text-sm">{activity.subtitle}</p>
                    </div>
                    <div className="bg-blue-50 px-3 py-1 rounded-full">
                      <span className="text-blue-600 font-semibold">{activity.score}%</span>
                    </div>
                  </div>
                </div>
              ))}
            </div>
          </section>

          {/* Próximas Avaliações */}
          <section>
            <div className="flex justify-between items-center mb-4">
              <h3 className="text-lg font-semibold">Próximas Avaliações</h3>
              <Link href="/exams" className="text-blue-600 hover:text-blue-700">
                Ver todas
              </Link>
            </div>
            <div className="space-y-4">
              {upcomingExams.map(exam => (
                <div key={exam.id} className="bg-white rounded-lg p-4 shadow-sm">
                  <div className="flex items-center mb-4">
                    <div className="bg-orange-100 rounded-full p-3 mr-4">
                      <svg xmlns="http://www.w3.org/2000/svg" className="h-6 w-6 text-orange-600" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                        <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z" />
                      </svg>
                    </div>
                    <div className="flex-1">
                      <h3 className="font-semibold">{exam.title}</h3>
                      <p className="text-gray-600 text-sm">
                        {exam.date.toLocaleDateString('pt-BR')} às {exam.date.toLocaleTimeString('pt-BR', { hour: '2-digit', minute: '2-digit' })}
                      </p>
                    </div>
                    <div className="bg-orange-50 px-3 py-1 rounded-full">
                      <span className="text-orange-600 font-semibold">Em breve</span>
                    </div>
                  </div>
                  <div className="flex flex-wrap gap-2">
                    {exam.subjects.map(subject => (
                      <span key={subject} className="bg-blue-50 text-blue-600 text-sm px-3 py-1 rounded-full">
                        {subject}
                      </span>
                    ))}
                  </div>
                </div>
              ))}
            </div>
          </section>
        </main>
      </div>

      {/* Notifications Modal */}
      {showNotifications && (
        <div className="fixed inset-0 bg-black bg-opacity-50 flex items-end justify-center sm:items-center p-4 z-50">
          <div className="bg-white rounded-t-2xl sm:rounded-xl w-full max-w-md">
            <div className="p-4 border-b">
              <div className="flex justify-between items-center">
                <h2 className="text-xl font-bold">Notificações</h2>
                <button
                  onClick={() => setShowNotifications(false)}
                  className="text-gray-500 hover:text-gray-700"
                >
                  <svg xmlns="http://www.w3.org/2000/svg" className="h-6 w-6" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M6 18L18 6M6 6l12 12" />
                  </svg>
                </button>
              </div>
            </div>
            <div className="p-4">
              <p className="text-center text-gray-500">Nenhuma notificação no momento</p>
            </div>
          </div>
        </div>
      )}

      {/* Overlay */}
      {showSidebar && (
        <div
          className="fixed inset-0 bg-black bg-opacity-50 z-40 lg:hidden"
          onClick={() => setShowSidebar(false)}
        />
      )}
    </div>
  )
} 