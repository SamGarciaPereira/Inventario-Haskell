module Logic where

import Types
import qualified Data.Map as Map
import Data.Time (UTCTime)

-- | sinônimo de tipo para agrupar o retorno das operações sobre o inventário
type ResultadoOperacao = (Inventario, LogEntry)

-- | insere um novo item no mapa do inventário se a chave correspondente ao id do item não existir
addItem :: UTCTime -> Item -> Inventario -> Either String ResultadoOperacao
addItem tempo novoItem inv
    | Map.member (itemID novoItem) inv = Left ("O item " ++ itemID novoItem ++ " ja esta cadastrado.")
    | otherwise = Right (novoInv, logEntry)
  where
    novoInv = Map.insert (itemID novoItem) novoItem inv
    -- o id deve ser a primeira palavra da string de detalhes para compatibilidade com relatórios
    detalheMsg = itemID novoItem ++ " adicionado com sucesso."
    logEntry = LogEntry tempo Add detalheMsg Sucesso

-- | deduz uma quantidade específica do estoque de um produto cadastrado
removeItem :: UTCTime -> String -> Int -> Inventario -> Either String ResultadoOperacao
removeItem tempo idBuscado qtdRemover inv =
    case Map.lookup idBuscado inv of
        Nothing -> 
            Left ("Item " ++ idBuscado ++ " nao encontrado no inventario.")
            
        Just itemAtual
            | qtdRemover > quantidade itemAtual -> 
                Left ("Estoque insuficiente para o item " ++ idBuscado ++ ". Disponivel: " ++ show (quantidade itemAtual))
                
            | otherwise -> 
                Right (novoInv, logEntry)
            where
                -- realiza a atualização cadastral modificando apenas o atributo de quantidade
                novoItem = itemAtual { quantidade = quantidade itemAtual - qtdRemover }
                novoInv = Map.insert idBuscado novoItem inv
                detalheMsg = idBuscado ++ " teve " ++ show qtdRemover ++ " unidades removidas."
                logEntry = LogEntry tempo Remove detalheMsg Sucesso

-- | substitui os dados de um item existente se o id for validado como pertencente ao mapa
updateItem :: UTCTime -> Item -> Inventario -> Either String ResultadoOperacao
updateItem tempo itemAtualizado inv
    | not (Map.member (itemID itemAtualizado) inv) = Left ("Item " ++ itemID itemAtualizado ++ " nao encontrado.")
    | otherwise = Right (novoInv, logEntry)
  where
    novoInv = Map.insert (itemID itemAtualizado) itemAtualizado inv
    detalheMsg = itemID itemAtualizado ++ " atualizado com sucesso."
    logEntry = LogEntry tempo Update detalheMsg Sucesso