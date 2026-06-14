module Types where

import qualified Data.Map as Map
import Data.Time (UTCTime)

-- tipo algébrico de dados para representar as operações possíveis no sistema de auditoria
data AcaoLog = Add | Remove | Update | QueryFail 
    deriving (Show, Read, Eq)

-- construtor de tipo para o resultado da operação, onde a falha armazena uma string com a causa
data StatusLog = Sucesso | Falha String 
    deriving (Show, Read, Eq)

-- | estrutura que define os atributos e campos de um produto do inventário
data Item = Item 
    { itemID     :: String
    , nome       :: String
    , quantidade :: Int
    , categoria  :: String
    } deriving (Show, Read, Eq)

-- | definição de um sinônimo de tipo estruturado como um mapa indexado pelo id do item
type Inventario = Map.Map String Item

-- | tipo de dado que modela uma entrada de evento a ser gravada no histórico de logs
data LogEntry = LogEntry
    { timestamp :: UTCTime
    , acao      :: AcaoLog
    , detalhes  :: String -- string explicativa iniciada pelo id do item para compatibilidade
    , status    :: StatusLog
    } deriving (Show, Read, Eq)