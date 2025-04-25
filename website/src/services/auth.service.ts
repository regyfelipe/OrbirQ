import { createClient } from '@supabase/supabase-js'

const supabaseUrl = process.env.NEXT_PUBLIC_SUPABASE_URL!
const supabaseKey = process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!

export const supabase = createClient(supabaseUrl, supabaseKey)

export type UserType = 'aluno' | 'professor'

export interface Profile {
  id: string
  email: string
  name: string
  user_type: UserType
  created_at?: string
  updated_at?: string
}

class AuthService {
  private static instance: AuthService
  private _currentUser: Profile | null = null
  private _isLoading = false
  private _error: string | null = null

  private constructor() {}

  static getInstance(): AuthService {
    if (!AuthService.instance) {
      AuthService.instance = new AuthService()
    }
    return AuthService.instance
  }

  get currentUser() {
    return this._currentUser
  }

  get isLoading() {
    return this._isLoading
  }

  get error() {
    return this._error
  }

  get supabase() {
    return supabase
  }

  async initialize() {
    // Adiciona listener para mudanças no estado de autenticação
    supabase.auth.onAuthStateChange(async (event, session) => {
      if (event === 'SIGNED_IN' && session) {
        await this._createInitialProfile(session.user)
      }
    })

    // Verifica sessão atual
    await this.checkCurrentSession()
  }

  private async _createInitialProfile(user: any) {
    try {
      console.log('Verificando/criando perfil para usuário', user.id)

      // Verifica se o perfil já existe
      const { data: existingProfile } = await supabase
        .from('profiles')
        .select()
        .eq('id', user.id)
        .maybeSingle()

      if (!existingProfile) {
        console.log('Perfil não encontrado, criando novo perfil...')

        // Cria o perfil se não existir
        await supabase.from('profiles').insert({
          id: user.id,
          email: user.email,
          name: user.email?.split('@')[0] ?? 'Usuário',
          user_type: 'aluno'
        })

        console.log('Perfil criado com sucesso')
      } else {
        console.log('Perfil já existe')
      }
    } catch (e) {
      console.error('Erro ao criar perfil:', e)
    }
  }

  async login(email: string, password: string): Promise<boolean> {
    try {
      this._error = null
      this._isLoading = true

      console.log('=== INICIANDO LOGIN ===')
      console.log('Email:', email)

      // 1. Tentar fazer login
      const { data: authData, error: authError } = await supabase.auth.signInWithPassword({
        email,
        password,
      })

      if (authError || !authData.user) {
        console.log('Login falhou:', authError?.message)
        this._error = 'Usuário ou senha inválidos'
        return false
      }

      console.log('Login bem sucedido. ID do usuário:', authData.user.id)

      // 2. Verificar se o perfil existe
      console.log('Verificando perfil existente...')
      const { data: profile } = await supabase
        .from('profiles')
        .select()
        .eq('id', authData.user.id)
        .maybeSingle()

      if (!profile) {
        console.log('Perfil não encontrado, criando novo perfil...')
        // 3. Criar perfil se não existir
        const newProfile: Profile = {
          id: authData.user.id,
          email: authData.user.email!,
          name: authData.user.email?.split('@')[0] ?? 'Usuário',
          user_type: 'aluno'
        }

        await supabase.from('profiles').insert(newProfile)
        console.log('Novo perfil criado com sucesso')

        this._currentUser = newProfile
      } else {
        console.log('Perfil encontrado:', profile)
        this._currentUser = profile
      }

      return true
    } catch (e) {
      console.error('=== ERRO NO LOGIN ===', e)
      this._error = this._handleError(e)
      return false
    } finally {
      this._isLoading = false
    }
  }

  async register(name: string, email: string, password: string, userType: UserType): Promise<boolean> {
    try {
      this._error = null
      this._isLoading = true

      console.log('=== INICIANDO REGISTRO ===')
      console.log('Email:', email)

      // 1. Verificar se já existe uma conta
      const { data: existingUser } = await supabase
        .from('profiles')
        .select()
        .eq('email', email)
        .maybeSingle()

      if (existingUser) {
        console.log('Email já registrado')
        this._error = 'Este email já está cadastrado no sistema'
        return false
      }

      console.log('Email disponível, prosseguindo com registro...')

      // 2. Realizar o cadastro do usuário no Auth
      const { data: authData, error: authError } = await supabase.auth.signUp({
        email,
        password,
        options: {
          data: { name, user_type: userType }
        }
      })

      if (authError || !authData.user) {
        console.log('Falha ao criar usuário no Auth')
        this._error = 'Falha ao criar usuário'
        return false
      }

      console.log('Usuário criado no Auth com sucesso. ID:', authData.user.id)

      // 3. Criar ou atualizar o perfil na tabela profiles
      const profile: Profile = {
        id: authData.user.id,
        name,
        email,
        user_type: userType,
      }

      const { error: profileError } = await supabase
        .from('profiles')
        .upsert(profile)

      if (profileError) {
        console.log('Erro ao criar perfil:', profileError)
        await supabase.auth.signOut()
        throw profileError
      }

      console.log('Perfil criado/atualizado com sucesso')
      this._currentUser = profile

      return true
    } catch (e) {
      console.error('=== ERRO NO REGISTRO ===', e)
      this._error = this._handleError(e)
      await supabase.auth.signOut()
      return false
    } finally {
      this._isLoading = false
    }
  }

  async resetPassword(email: string): Promise<boolean> {
    try {
      this._error = null
      this._isLoading = true

      const { error } = await supabase.auth.resetPasswordForEmail(email, {
        redirectTo: `${window.location.origin}/reset-password`,
      })

      if (error) throw error
      return true
    } catch (e) {
      this._error = this._handleError(e)
      return false
    } finally {
      this._isLoading = false
    }
  }

  async logout(): Promise<void> {
    try {
      await supabase.auth.signOut()
      this._currentUser = null
    } catch (e) {
      this._error = this._handleError(e)
    }
  }

  async checkCurrentSession(): Promise<boolean> {
    try {
      const { data: { session } } = await supabase.auth.getSession()

      if (session?.user) {
        // Buscar o perfil completo do usuário
        const { data: profile } = await supabase
          .from('profiles')
          .select()
          .eq('id', session.user.id)
          .maybeSingle()

        if (profile) {
          this._currentUser = profile
          await this._createInitialProfile(session.user)
          return true
        } else {
          this._error = 'Perfil do usuário não encontrado'
          return false
        }
      }
      return false
    } catch (e) {
      this._error = this._handleError(e)
      return false
    }
  }

  private _handleError(e: any): string {
    console.error('Erro original:', e)

    if (e?.message) {
      switch (e.message) {
        case 'Invalid login credentials':
          return 'Email ou senha inválidos'
        case 'Email not confirmed':
          return 'Por favor, confirme seu email antes de fazer login'
        case 'User already registered':
          return 'Este email já está cadastrado no sistema'
        case 'Password should be at least 6 characters':
          return 'A senha deve ter pelo menos 6 caracteres'
        case 'Invalid email':
          return 'O email fornecido é inválido'
        default:
          return `Erro: ${e.message}`
      }
    }

    return 'Ocorreu um erro inesperado. Por favor, tente novamente.'
  }
}

export const authService = AuthService.getInstance() 