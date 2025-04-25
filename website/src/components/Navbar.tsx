'use client'

import { useEffect, useState } from 'react'
import Link from 'next/link'
import { useRouter } from 'next/navigation'
import { supabase } from '@/services/supabase'
import { User } from '@supabase/supabase-js'

export default function Navbar() {
  const router = useRouter()
  const [user, setUser] = useState<User | null>(null)
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    checkUser()
    const { data: authListener } = supabase.auth.onAuthStateChange(async (event, session) => {
      setUser(session?.user ?? null)
      setLoading(false)
    })

    return () => {
      if (authListener?.subscription) {
        authListener.subscription.unsubscribe()
      }
    }
  }, [])

  async function checkUser() {
    try {
      const { data: { user } } = await supabase.auth.getUser()
      setUser(user)
    } catch (error) {
      console.error('Erro ao verificar usuário:', error)
    } finally {
      setLoading(false)
    }
  }

  async function handleSignOut() {
    try {
      await supabase.auth.signOut()
      router.push('/login')
    } catch (error) {
      console.error('Erro ao fazer logout:', error)
    }
  }

  return (
    <nav className="bg-[#0A0A0A] text-white p-4">
      <div className="container mx-auto flex justify-between items-center">
        <Link href={user ? "/home" : "/"} className="text-xl font-bold">
          Orbirq
        </Link>
        
        <div className="flex items-center gap-6">
          {!loading && (
            <>
              {user ? (
                <>
                  <Link href="/home" className="hover:text-gray-300">
                    Início
                  </Link>
                  <Link href="/questions" className="hover:text-gray-300">
                    Questões
                  </Link>
                  <Link href="/tasks" className="hover:text-gray-300">
                    Tarefas
                  </Link>
                  <button
                    onClick={handleSignOut}
                    className="bg-primary px-4 py-2 rounded hover:bg-primary/80"
                  >
                    Sair
                  </button>
                </>
              ) : (
                <Link
                  href="/login"
                  className="bg-primary px-4 py-2 rounded hover:bg-primary/80"
                >
                  Entrar
                </Link>
              )}
            </>
          )}
        </div>
      </div>
    </nav>
  )
} 