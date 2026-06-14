module Main where

import Types
import Logic
import Reports

import qualified Data.Map as Map
import Data.Time (getCurrentTime)
import System.IO (stdout, hFlush, appendFile, writeFile, readFile)
import Control.Exception (catch, IOException)

-- Equipe:
-- Abílio Pedro Alcântara Mota Batista
-- Beatriz Ceciliato Robaskievicz da Cunha
-- Samuel Garcia Pereira

-- 1. Persistência de dados (i/o)
-- ==========================================

-- | tenta ler o inventário do arquivo. caso o arquivo não exista ou esteja vazio,
-- retorna um mapa vazio por meio do tratamento de exceção.
carregarInventario :: IO Inventario
carregarInventario = catch (do
    conteudo <- readFile "Inventario.dat"
    -- validação da string lida para evitar falhas no parse com a função read
    if null conteudo 
        then return Map.empty 
        else return (read conteudo))
    (\e -> const (return Map.empty) (e :: IOException))

-- | lê o arquivo de auditoria linha por linha e converte o texto para o tipo logentry. 
carregarLogs :: IO [LogEntry]
carregarLogs = catch (do
    conteudo <- readFile "Auditoria.log"
    -- tratamento para evitar erros em arquivos de log vazios
    if null conteudo
        then return []
        else return (map read (lines conteudo)))
    (\e -> const (return []) (e :: IOException))

-- | sobrescreve o arquivo local com a representação em texto do inventário atual.
salvarInventario :: Inventario -> IO ()
salvarInventario inv = writeFile "Inventario.dat" (show inv)

-- | anexa uma nova linha com os dados de uma operação ao final do arquivo de logs.
registrarLog :: LogEntry -> IO ()
registrarLog logEntry = appendFile "Auditoria.log" (show logEntry ++ "\n")

-- 2. Loop principal e menus
-- ==========================================

-- | função de entrada do programa que carrega os dados e inicia o fluxo iterativo
main :: IO ()
main = do
    putStrLn "Iniciando Sistema de Inventario..."
    invInicial <- carregarInventario
    loopMain invInicial

-- | laço recursivo que exibe as opções do terminal e processa a entrada selecionada
loopMain :: Inventario -> IO ()
loopMain inv = do
    putStrLn "\n====================================="
    putStrLn "   SISTEMA DE GESTAO DE INVENTARIO   "
    putStrLn "====================================="
    putStrLn "1. Adicionar Novo Item"
    putStrLn "2. Remover Estoque de um Item"
    putStrLn "3. Listar Inventario Atual"
    putStrLn "4. Relatorios (Analisar Logs)"
    putStrLn "5. Sair"
    putStr "Escolha uma opcao: "
    hFlush stdout
    
    opcao <- getLine
    case opcao of
        "1" -> menuAdicionar inv
        "2" -> menuRemover inv
        "3" -> listarInventario inv >> loopMain inv
        "4" -> gerarRelatorios inv >> loopMain inv
        "5" -> putStrLn "Saindo e encerrando o sistema..."
        _   -> do
            putStrLn "\nOpcao invalida! Tente novamente."
            loopMain inv

-- 3. Ações do usuário
-- ==========================================

-- | coleta os dados do terminal e envia para a função de inserção do módulo purificado
menuAdicionar :: Inventario -> IO ()
menuAdicionar inv = do
    putStrLn "\n--- Adicionar Novo Item ---"
    putStr "ID do Item: "; hFlush stdout; idNovo <- getLine
    putStr "Nome do Item: "; hFlush stdout; nomeNovo <- getLine
    putStr "Quantidade: "; hFlush stdout; qtdStr <- getLine
    putStr "Categoria: "; hFlush stdout; catNova <- getLine
    
    let qtdNum = read qtdStr :: Int
    let novoItem = Item idNovo nomeNovo qtdNum catNova
    
    tempo <- getCurrentTime
    
    -- avaliação do resultado retornado pela regra de negócio pura
    case addItem tempo novoItem inv of
        Right (novoInv, logSucesso) -> do
            salvarInventario novoInv
            registrarLog logSucesso
            putStrLn $ "\nSucesso: " ++ detalhes logSucesso
            loopMain novoInv
            
        Left erroMsg -> do
            let logErro = LogEntry tempo Add erroMsg (Falha erroMsg)
            registrarLog logErro
            putStrLn $ "\nFalha na operacao: " ++ erroMsg
            loopMain inv

-- | solicita o id e a quantidade para realizar a baixa de um produto do mapa
menuRemover :: Inventario -> IO ()
menuRemover inv = do
    putStrLn "\n--- Remover Estoque ---"
    putStr "ID do Item: "; hFlush stdout; idBuscado <- getLine
    putStr "Quantidade a remover: "; hFlush stdout; qtdStr <- getLine
    
    let qtdNum = read qtdStr :: Int
    tempo <- getCurrentTime
    
    -- chamada do componente funcional para a dedução da retirada de estoque
    case removeItem tempo idBuscado qtdNum inv of
        Right (novoInv, logSucesso) -> do
            salvarInventario novoInv
            registrarLog logSucesso
            putStrLn $ "\nSucesso: " ++ detalhes logSucesso
            loopMain novoInv
            
        Left erroMsg -> do
            -- salvamento da ocorrência de falha no arquivo histórico para geração de relatórios
            let logErro = LogEntry tempo Remove erroMsg (Falha erroMsg)
            registrarLog logErro
            putStrLn $ "\nFalha na operacao: " ++ erroMsg
            loopMain inv

-- 4. Consultas e relatórios
-- ==========================================

-- | percorre o mapa da memória e imprime a formatação textual de cada item estruturado
listarInventario :: Inventario -> IO ()
listarInventario inv = do
    putStrLn "\n--- Inventario Atual ---"
    if Map.null inv
        then putStrLn "O inventario esta completamente vazio."
        else mapM_ (\(k, v) -> putStrLn $ "ID: " ++ k ++ " | Nome: " ++ nome v ++ " | Qtd: " ++ show (quantidade v) ++ " | Cat: " ++ categoria v) (Map.toList inv)

-- | efetua a leitura das linhas de log e aplica as funções analíticas de ordenação e filtragem
gerarRelatorios :: Inventario -> IO ()
gerarRelatorios _ = do
    putStrLn "\n--- Gerando Relatorios a partir do Log ---"
    logs <- carregarLogs
    if null logs
        then putStrLn "Nenhum log registrado ainda."
        else do
            putStrLn $ "-> Total de operacoes registradas: " ++ show (length logs)
            
            putStrLn "\n-> Item Mais Movimentado com Sucesso:"
            putStrLn $ "   ID: " ++ itemMaisMovimentado logs
            
            putStrLn "\n-> Historico de Falhas:"
            let erros = logsDeErro logs
            if null erros
                then putStrLn "   Nenhum erro registrado."
                else mapM_ (\l -> putStrLn $ "   [" ++ show (timestamp l) ++ "] " ++ detalhes l) erros