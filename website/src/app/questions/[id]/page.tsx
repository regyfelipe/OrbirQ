'use client'

import { useEffect, useState } from 'react'
import { useParams, useRouter } from 'next/navigation'
import QuestoesService, { Questao } from '@/services/questoes.service'
import { FaArrowLeft, FaArrowRight } from 'react-icons/fa'
import Image from 'next/image'

export default function QuestaoPage() {
  const router = useRouter()
  const params = useParams()
  const [questao, setQuestao] = useState<Questao | null>(null)
  const [loading, setLoading] = useState(true)
  const [respostaSelecionada, setRespostaSelecionada] = useState<string>('')
  const [mostrarResposta, setMostrarResposta] = useState(false)
  const [numeroQuestao, setNumeroQuestao] = useState(0)

  useEffect(() => {
    carregarQuestao()
  }, [params.id])

  const carregarQuestao = async () => {
    setLoading(true)
    try {
      const questaoId = params.id as string
      const questao = await QuestoesService.getQuestaoPorId(questaoId)
      const numero = await QuestoesService.getQuestaoNumero(questaoId)
      setQuestao(questao)
      setNumeroQuestao(numero)
      setRespostaSelecionada('')
      setMostrarResposta(false)
    } catch (error) {
      console.error('Erro ao carregar questão:', error)
    } finally {
      setLoading(false)
    }
  }

  const navegarParaQuestao = (direcao: 'anterior' | 'proxima') => {
    const novoNumero = direcao === 'anterior' ? numeroQuestao - 1 : numeroQuestao + 1
    if (novoNumero > 0) {
      router.push(`/questions/${novoNumero}`)
    }
  }

  if (loading) {
    return (
      <div className="flex items-center justify-center min-h-screen">
        <div className="animate-spin rounded-full h-12 w-12 border-t-2 border-b-2 border-primary"></div>
      </div>
    )
  }

  if (!questao) {
    return (
      <div className="flex flex-col items-center justify-center min-h-screen">
        <h1 className="text-2xl font-bold mb-4">Questão não encontrada</h1>
        <button
          onClick={() => router.push('/questions')}
          className="px-4 py-2 bg-primary text-white rounded hover:bg-primary/80"
        >
          Voltar para lista
        </button>
      </div>
    )
  }

  return (
    <div className="container mx-auto px-4 py-8">
      {/* Cabeçalho */}
      <div className="flex justify-between items-center mb-8">
        <button
          onClick={() => router.push('/questions')}
          className="flex items-center text-primary hover:text-primary/80"
        >
          <FaArrowLeft className="mr-2" />
          Voltar para lista
        </button>
        <div className="text-lg font-semibold">Questão {numeroQuestao}</div>
      </div>

      {/* Informações da questão */}
      <div className="bg-white rounded-lg shadow-md p-6 mb-6">
        <div className="flex flex-wrap gap-4 mb-4 text-sm text-gray-600">
          <div>
            <span className="font-semibold">Disciplina:</span> {questao.disciplina}
          </div>
          <div>
            <span className="font-semibold">Assunto:</span> {questao.assunto}
          </div>
          {questao.banca && (
            <div>
              <span className="font-semibold">Banca:</span> {questao.banca}
            </div>
          )}
          {questao.ano && (
            <div>
              <span className="font-semibold">Ano:</span> {questao.ano}
            </div>
          )}
        </div>

        {/* Texto de apoio */}
        {questao.textoApoio && (
          <div className="mb-6 p-4 bg-gray-50 rounded">
            <div className="font-semibold mb-2">Texto de Apoio:</div>
            <div className="text-gray-700">{questao.textoApoio}</div>
          </div>
        )}

        {/* Imagem */}
        {questao.imagemPath && (
          <div className="mb-6">
            <Image
              src={questao.imagemPath}
              alt="Imagem da questão"
              width={600}
              height={400}
              className="rounded-lg"
            />
          </div>
        )}

        {/* Pergunta */}
        <div className="mb-6">
          <div className="font-semibold mb-2">Pergunta:</div>
          <div className="text-gray-700">{questao.pergunta}</div>
        </div>

        {/* Alternativas */}
        <div className="space-y-4">
          {questao.alternativas.map((alternativa, index) => {
            const letra = String.fromCharCode(65 + index)
            const isSelected = respostaSelecionada === letra
            const isCorreta = mostrarResposta && letra === questao.resposta
            const isIncorreta = mostrarResposta && isSelected && letra !== questao.resposta

            return (
              <div
                key={letra}
                onClick={() => !mostrarResposta && setRespostaSelecionada(letra)}
                className={`p-4 rounded-lg cursor-pointer transition-colors ${
                  isSelected
                    ? 'bg-primary/10 border-primary'
                    : 'hover:bg-gray-50 border-transparent'
                } ${isCorreta ? 'bg-green-100' : ''} ${
                  isIncorreta ? 'bg-red-100' : ''
                } border-2`}
              >
                <div className="flex items-start">
                  <div className="font-semibold mr-2">{letra})</div>
                  <div>{alternativa}</div>
                </div>
              </div>
            )
          })}
        </div>

        {/* Botões de ação */}
        <div className="mt-8 flex justify-between items-center">
          <div className="flex gap-4">
            <button
              onClick={() => navegarParaQuestao('anterior')}
              disabled={numeroQuestao <= 1}
              className="px-4 py-2 flex items-center bg-gray-100 text-gray-700 rounded hover:bg-gray-200 disabled:opacity-50 disabled:cursor-not-allowed"
            >
              <FaArrowLeft className="mr-2" />
              Anterior
            </button>
            <button
              onClick={() => navegarParaQuestao('proxima')}
              className="px-4 py-2 flex items-center bg-gray-100 text-gray-700 rounded hover:bg-gray-200"
            >
              Próxima
              <FaArrowRight className="ml-2" />
            </button>
          </div>

          <button
            onClick={() => setMostrarResposta(true)}
            disabled={!respostaSelecionada || mostrarResposta}
            className="px-6 py-2 bg-primary text-white rounded hover:bg-primary/80 disabled:opacity-50 disabled:cursor-not-allowed"
          >
            Verificar
          </button>
        </div>

        {/* Explicação */}
        {mostrarResposta && questao.explicacao && (
          <div className="mt-8 p-4 bg-gray-50 rounded">
            <div className="font-semibold mb-2">Explicação:</div>
            <div className="text-gray-700">{questao.explicacao}</div>
          </div>
        )}
      </div>
    </div>
  )
} 