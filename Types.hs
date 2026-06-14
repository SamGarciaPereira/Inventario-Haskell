module Types where

import qualified Data.Map as Map
import Data.Time (UTCTime)

-- ADT para o tipo de ação registrada no sistema
data AcaoLog = Add | Remove | Update | QueryFail 
    deriving (Show, Read, Eq)

-- ADT para o resultado da operação. 'Falha' carrega o motivo do erro.
data StatusLog = Sucesso | Falha String 
    deriving (Show, Read, Eq)

-- | O modelo principal do Item do inventário
data Item = Item 
    { itemID     :: String
    , nome       :: String
    , quantidade :: Int
    , categoria  :: String
    } deriving (Show, Read, Eq)

-- | Sinônimo de tipo: O inventário é um Dicionário (Map) mapeando a String (itemID) para o Item
type Inventario = Map.Map String Item

-- | Registro para cada entrada no arquivo de auditoria
data LogEntry = LogEntry
    { timestamp :: UTCTime
    , acao      :: AcaoLog
    , detalhes  :: String     -- O Dev 2 deve colocar o itemID como a primeira palavra aqui (ex: "IT01 adicionado com sucesso")
    , status    :: StatusLog
    } deriving (Show, Read, Eq)