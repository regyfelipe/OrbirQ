'use client'

import { useState, FormEvent } from 'react'
import Image from 'next/image'
import Link from 'next/link'

export default function ForgotPasswordPage() {
  const [email, setEmail] = useState('')
  const [isLoading, setIsLoading] = useState(false)
  const [error, setError] = useState('')
  const [emailSent, setEmailSent] = useState(false)

  const handleSubmit = async (e: FormEvent) => {
    e.preventDefault()
    setIsLoading(true)
    setError('')

    try {
      // Simulando uma chamada de API
      await new Promise(resolve => setTimeout(resolve, 1000))
      
      // TODO: Implementar recuperação de senha real
      console.log('Recuperação de senha para:', email)
      
      setEmailSent(true)
    } catch (err) {
      setError('Ocorreu um erro ao enviar o e-mail. Tente novamente.')
    } finally {
      setIsLoading(false)
    }
  }

  return (
    <div className="min-h-screen bg-gray-900 text-white">
      <div className="container mx-auto px-4 py-8">
        <div className="max-w-md mx-auto">
          {/* Logo */}
          <div className="text-center mb-10">
            <Image
              src="/logo_txt.png"
              alt="Orbirq Logo"
              width={60}
              height={60}
              className="mx-auto"
              priority
            />
          </div>

          {emailSent ? (
            // Mensagem de sucesso
            <div className="bg-gray-800 p-8 rounded-lg text-center">
              <div className="mb-6 inline-flex items-center justify-center w-16 h-16 rounded-full bg-green-500/10">
                <svg xmlns="http://www.w3.org/2000/svg" className="h-8 w-8 text-green-500" viewBox="0 0 20 20" fill="currentColor">
                  <path fillRule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zm3.707-9.293a1 1 0 00-1.414-1.414L9 10.586 7.707 9.293a1 1 0 00-1.414 1.414l2 2a1 1 0 001.414 0l4-4z" clipRule="evenodd" />
                </svg>
              </div>
              <h2 className="text-xl font-bold mb-4">E-mail enviado!</h2>
              <p className="text-gray-400 mb-8">
                Verifique sua caixa de entrada e siga as instruções para recuperar sua senha.
              </p>
              <Link
                href="/login"
                className="inline-block w-full bg-blue-600 hover:bg-blue-700 text-white font-semibold py-4 rounded-lg transition-colors"
              >
                Voltar para login
              </Link>
            </div>
          ) : (
            // Formulário de recuperação
            <div>
              <h1 className="text-2xl font-bold mb-2">Esqueceu a senha?</h1>
              <p className="text-gray-400 mb-8">
                Digite seu e-mail para receber um link de recuperação de senha
              </p>

              <form onSubmit={handleSubmit} className="space-y-6">
                {/* Campo de Email */}
                <div>
                  <label className="block text-sm font-medium mb-2">
                    E-mail
                  </label>
                  <input
                    type="email"
                    value={email}
                    onChange={(e) => setEmail(e.target.value)}
                    placeholder="exemplo@gmail.com"
                    className="w-full px-3 py-4 bg-gray-800 rounded-lg border-none focus:ring-2 focus:ring-blue-500 text-white placeholder-gray-400"
                    required
                  />
                </div>

                {/* Mensagem de erro */}
                {error && (
                  <div className="bg-red-500/10 border border-red-500 text-red-500 px-4 py-3 rounded-lg">
                    {error}
                  </div>
                )}

                {/* Botão de Enviar */}
                <button
                  type="submit"
                  disabled={isLoading}
                  className="w-full bg-blue-600 hover:bg-blue-700 text-white font-semibold py-4 rounded-lg transition-colors disabled:bg-blue-800 disabled:cursor-not-allowed"
                >
                  {isLoading ? (
                    <div className="flex items-center justify-center">
                      <div className="w-5 h-5 border-2 border-white border-t-transparent rounded-full animate-spin"></div>
                    </div>
                  ) : (
                    'Enviar link'
                  )}
                </button>

                {/* Link para Login */}
                <div className="text-center mt-6">
                  <span className="text-gray-400">Lembrou sua senha?</span>
                  <Link
                    href="/login"
                    className="text-blue-500 hover:text-blue-400 ml-2 font-semibold"
                  >
                    Voltar para login
                  </Link>
                </div>
              </form>
            </div>
          )}
        </div>
      </div>
    </div>
  )
} 