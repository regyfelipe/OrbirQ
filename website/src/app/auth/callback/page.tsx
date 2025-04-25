'use client'

import { useEffect } from 'react'
import { useRouter } from 'next/navigation'
import { authService } from '@/services/auth.service'

export default function AuthCallbackPage() {
  const router = useRouter()

  useEffect(() => {
    const handleCallback = async () => {
      try {
        const isAuthenticated = await authService.checkCurrentSession()
        if (isAuthenticated) {
          router.push('/home')
        } else {
          router.push('/login')
        }
      } catch (error) {
        console.error('Erro no callback:', error)
        router.push('/login')
      }
    }

    handleCallback()
  }, [router])

  return (
    <div className="min-h-screen bg-gray-900 text-white flex items-center justify-center">
      <div className="text-center">
        <div className="w-16 h-16 border-4 border-blue-600 border-t-transparent rounded-full animate-spin mx-auto mb-4"></div>
        <p className="text-lg">Autenticando...</p>
      </div>
    </div>
  )
} 