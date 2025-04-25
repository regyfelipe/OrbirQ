import { Filter, Question } from '@/lib/supabase'
import { supabase } from '@/lib/supabase'

interface FiltrosQuestoes {
  disciplina?: string[]
  banca?: string[]
  ano?: string[]
  search?: string
  cargo?: string
  assunto?: string
  instituicao?: string
  regiao?: string
  areaAtuacao?: string
  modalidade?: string
  dificuldade?: string
}

export interface Questao {
  id: string
  professor_id: string
  disciplina: string
  assunto: string
  autor?: string
  isInedita: boolean
  ano: string
  banca: string
  orgao?: string
  textoApoio?: string
  imagemPath?: string
  pergunta: string
  alternativas: string[]
  resposta: string
  explicacao: string
  isPublic: boolean
  createdAt?: Date
  updatedAt?: Date
}

export class QuestoesService {
  static async carregarQuestoes(filtros: Filter): Promise<Question[]> {
    try {
      let query = supabase
        .from('questions')
        .select(`
          *,
          alternatives (*),
          comments (
            *,
            user (
              name,
              avatar_url
            )
          ),
          statistics (*)
        `)
        .order('created_at', { ascending: false })

      if (filtros.discipline) {
        query = query.eq('discipline', filtros.discipline)
      }
      if (filtros.bank) {
        query = query.eq('bank', filtros.bank)
      }
      if (filtros.year) {
        query = query.eq('year', filtros.year)
      }
      if (filtros.search) {
        query = query.ilike('content', `%${filtros.search}%`)
      }

      const { data, error } = await query

      if (error) throw error

      return data as Question[]
    } catch (error) {
      console.error('Erro ao carregar questões:', error)
      return []
    }
  }

  static async carregarFiltros() {
    try {
      const { data: questions, error } = await supabase
        .from('questions')
        .select('discipline, bank, year')

      if (error) throw error

      const disciplines = [...new Set(questions.map(q => q.discipline))].sort()
      const banks = [...new Set(questions.map(q => q.bank))].sort()
      const years = [...new Set(questions.map(q => q.year))].sort((a, b) => b - a)

      return {
        disciplines,
        banks,
        years
      }
    } catch (error) {
      console.error('Erro ao carregar filtros:', error)
      return {
        disciplines: [],
        banks: [],
        years: []
      }
    }
  }

  async getQuestaoPorId(id: string): Promise<Questao | null> {
    try {
      const { data, error } = await supabase
        .from('questions')
        .select()
        .eq('id', id)
        .single();

      if (error) throw error;

      return this.mapQuestao(data);
    } catch (error) {
      console.error('Erro ao buscar questão por ID:', error);
      return null;
    }
  }

  async getQuestaoNumero(id: string): Promise<number> {
    try {
      const { data, error } = await supabase
        .from('questions')
        .select('id')
        .order('created_at', { ascending: true });

      if (error) throw error;

      const index = data.findIndex((q) => q.id === id);
      return index + 1;
    } catch (error) {
      console.error('Erro ao buscar número da questão:', error);
      return 0;
    }
  }

  private mapQuestao(data: any): Questao {
    return {
      id: data.id,
      professor_id: data.professor_id,
      disciplina: data.disciplina,
      assunto: data.assunto,
      autor: data.autor,
      isInedita: data.is_inedita || false,
      ano: data.ano,
      banca: data.banca,
      orgao: data.orgao,
      textoApoio: data.texto_apoio,
      imagemPath: data.imagem_url,
      pergunta: data.pergunta,
      alternativas: data.alternativas,
      resposta: data.resposta,
      explicacao: data.explicacao,
      isPublic: data.is_public || false,
      createdAt: data.created_at ? new Date(data.created_at) : undefined,
      updatedAt: data.updated_at ? new Date(data.updated_at) : undefined,
    };
  }
}

export default new QuestoesService(); 