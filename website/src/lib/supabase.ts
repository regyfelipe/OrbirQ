import { createClient } from '@supabase/supabase-js'

const supabaseUrl = process.env.NEXT_PUBLIC_SUPABASE_URL!
const supabaseAnonKey = process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!

export const supabase = createClient(supabaseUrl, supabaseAnonKey)

export interface Question {
  id: number
  title: string
  content: string
  discipline: string
  bank: string
  year: number
  created_at: string
  alternatives: Alternative[]
  explanation?: string
  comments?: Comment[]
  statistics?: Statistics
}

export interface Alternative {
  id: number
  content: string
  is_correct: boolean
}

export interface Comment {
  id: number
  user_id: string
  content: string
  created_at: string
  user: {
    name: string
    avatar_url?: string
  }
}

export interface Statistics {
  total_answers: number
  correct_answers: number
  incorrect_answers: number
}

export interface Filter {
  discipline?: string
  bank?: string
  year?: number
  search?: string
} 