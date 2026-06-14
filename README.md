# Sistema de Gestão de Inventário em Haskell

**Instituição:** Pontifícia Universidade Católica do Paraná (PUCPR)
**Disciplina:** Programação Lógica e Funcional
**Professor:** Eduardo Lino

## Integrantes
- Abílio Pedro Alcântara Mota Batista | Github: @oabilio
- Beatriz Ceciliato Robaskievicz da Cunha | Github: @biacrcunha
- Samuel Garcia Pereira | Github: @SamGarciaPereira

## Link Compilador Online (GDB)
https://onlinegdb.com/fkprl4S9F

---

## Dados Mínimos de Teste
O sistema foi previamente populado com **10 itens distintos** para permitir a execução real e validação das lógicas de relatório e movimentação de negócio. Os arquivos de banco de dados (`Inventario.dat`) e histórico (`Auditoria.log`) contendo esta carga inicial obrigatória acompanham este repositório.

---

## Documentação dos Cenários de Teste Manuais

Para garantir a confiabilidade da nossa separação entre lógica pura e efeitos colaterais (I/O), o sistema foi submetido à seguinte bateria de testes manuais, obtendo êxito em todos os requisitos.

### Cenário 1: Persistência de Estado (Sucesso)
* **Objetivo:** Garantir a criação dos arquivos em disco e o carregamento correto do estado anterior (Desserialização).
* **Passos Executados:**
    1. O programa foi iniciado em um diretório limpo (sem arquivos `.dat` e `.log` preexistentes).
    2. Através do menu interativo (opção 1), foram adicionados 3 itens distintos no inventário.
    3. O programa foi encerrado utilizando a opção "5. Sair".
    4. Validou-se fisicamente no diretório que os arquivos `Inventario.dat` e `Auditoria.log` foram instanciados corretamente pelo sistema.
    5. O programa foi reiniciado.
    6. A opção "3. Listar Inventario Atual" foi solicitada no menu.
* **Resultado Obtido:** O estado carregado para a memória recriou o `Data.Map` corretamente, exibindo os 3 itens inseridos na sessão anterior, atestando o funcionamento da função `carregarInventario`.

### Cenário 2: Erro de Lógica (Estoque Insuficiente)
* **Objetivo:** Validar o bloqueio transacional (usando a mônada `Either`) em casos de regras de negócio violadas e o registro de auditoria da falha.
* **Passos Executados:**
    1. Foi cadastrado no sistema um item de teste (ex: `TEC01` - Teclado) com o estoque de **10 unidades**.
    2. Foi acionada a opção "2. Remover Estoque de um Item".
    3. Solicitou-se ao sistema a remoção de **15 unidades** do item cadastrado.
* **Resultado Obtido:** A função pura de negócio barrou a operação adequadamente.
    * O programa emitiu imediatamente no terminal o alerta: `Falha na operacao: Estoque insuficiente...`.
    * Ao executar a opção "3. Listar Inventario", o estado em memória e no disco continuavam inalterados, preservando as 10 unidades originais.
    * A leitura do arquivo `Auditoria.log` confirmou o registro imutável do erro, gravando uma linha com o status contendo o construtor `Falha`.

### Cenário 3: Geração de Relatório de Erros
* **Objetivo:** Comprovar o processamento puro dos logs gerados no sistema para exibição de estatísticas e auditorias.
* **Passos Executados:**
    1. Imediatamente após a execução da falha de estoque descrita no Cenário 2, manteve-se o programa aberto.
    2. Executou-se a opção "4. Relatorios (Analisar Logs)".
* **Resultado Obtido:** A função purificada `logsDeErro` filtrou as entradas de log carregadas e gerou com sucesso a saída de tela na seção `-> Historico de Falhas:`, listando textualmente a tentativa frustrada de remoção de estoque oriunda do cenário anterior.
