module Reports where

import Types
import Data.List (isInfixOf, group, sort, maximumBy)
import Data.Ord (comparing)

-- | filtra a lista de logs para retornar apenas os registros que falharam
logsDeErro :: [LogEntry] -> [LogEntry]
logsDeErro = filter ehFalha
  where
    -- avaliação por correspondência de padrões para identificar o construtor de falha
    ehFalha log = case status log of
        Falha _ -> True
        _       -> False

-- | varre o histórico aplicando um filtro para encontrar o id buscado dentro do campo de detalhes
historicoPorItem :: String -> [LogEntry] -> [LogEntry]
historicoPorItem idBuscado = filter (\log -> idBuscado `isInfixOf` detalhes log)

-- | identifica qual identificador de item teve a maior recorrência em operações bem-sucedidas
itemMaisMovimentado :: [LogEntry] -> String
itemMaisMovimentado [] = "Nenhum log registrado."
itemMaisMovimentado logs = 
    let -- remove todas as entradas que não possuem status de sucesso
        logsSucesso = filter (\l -> status l == Sucesso) logs

        -- função auxiliar para extrair de forma segura o primeiro elemento gerado por words
        pegarPrimeiraPalavra :: String -> String
        pegarPrimeiraPalavra texto = case words texto of
            (primeira:_) -> primeira
            []           -> "ID_Desconhecido"

        -- aplica a função em mapeamento sobre a lista para isolar os identificadores
        idsMovimentados = map (pegarPrimeiraPalavra . detalhes) logsSucesso

        -- agrupamento dos identificadores após ordenação para aglutinar chaves idênticas
        grupos = group (sort idsMovimentados)

    in if null idsMovimentados 
       then "Nenhuma movimentacao com sucesso encontrada." 
       else 
           -- determinação do subconjunto com maior número de elementos e casamento de padrões no retorno
           let maiorGrupo = maximumBy (comparing length) grupos
           in case maiorGrupo of
               (itemMaisFrequente:_) -> itemMaisFrequente
               []                    -> "Erro_Inesperado"