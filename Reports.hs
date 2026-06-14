module Reports where

import Types
import Data.List (isInfixOf, group, sort, maximumBy)
import Data.Ord (comparing)

-- Analisa a lista completa de logs e retorna apenas as operações que falharam.
logsDeErro :: [LogEntry] -> [LogEntry]
logsDeErro = filter ehFalha
  where
    -- Faz pattern matching no statusLog para identificar o construtor 'Falha'
    ehFalha log = case status log of
        Falha _ -> True
        _       -> False

-- Filtra o histórico procurando qualquer log que mencione o ID buscado nos detalhes.
historicoPorItem :: String -> [LogEntry] -> [LogEntry]
historicoPorItem idBuscado = filter (\log -> idBuscado `isInfixOf` detalhes log)

-- Identifica qual item teve o maior volume de transações de sucesso.
-- Assume que a primeira palavra na string 'detalhes' do log é o itemID 
itemMaisMovimentado :: [LogEntry] -> String
itemMaisMovimentado [] = "Nenhum log registrado."
itemMaisMovimentado logs = 
    let -- Mantém apenas os logs que deram Sucesso
        logsSucesso = filter (\l -> status l == Sucesso) logs

        -- Extrai a primeira palavra dos detalhes de cada log (ID)
        idsMovimentados = map (head . words . detalhes) logsSucesso

        -- Agrupa IDs idênticos em sublistas: ["IT01", "IT01"], ["IT02"]
        grupos = group (sort idsMovimentados)

    in if null idsMovimentados 
       then "Nenhuma movimentação com sucesso encontrada." 
       else head (maximumBy (comparing length) grupos) -- Retorna o elemento da sublista mais longa
