# Páginas de Dados. Onde seus dados moram

### 01 - Estrutura de uma pagina de dados

PÁGINA DE DADOS - 8Kb ou 8192 bytes

--------------------------------------------------------
           CABEÇALHO (HEADER) DA PÁGINA - 96 BYTES

--------------------------------------------------------     

                      ÁREA DE DADOS

         TAMANHO MÁXIMO DE UMA LINHA : 8060 BYTES

--------------------------------------------------------
MATRIZ DOS SLOTS - 2 BYTES POR LINHA           ||||
--------------------------------------------------------

Uma página de dados é exclusiva de um objeto de alocação de dados (Tabela ou Índice).

- <b>Cabeçalho</b>      : ID da Página, ID do Objeto, Tipo de Página, espaço livre, etc.....
- <b>Área de Dados</b>  : Onde as linhas serão armazanadas. Alocadas em série, a partir do final do cabeçalho.
                 Cada linha tem o limite de 8060 bytes.
- <b>Matriz de Slot</b> : Uma tabela que contém para cada linha, a posição que ele se inicia dentro da página.
                 Também conhecida como tabela de deslocamento de linha ou offset row.

Considerando a área de dados e matriz de slots, temos 8.096 bytes para armazenamento.

Ref.: 
https://docs.microsoft.com/pt-br/sql/relational-databases/pages-and-extents-architecture-guide

Vamos verificar um comando que será muito utilizado

Set statistics io

Quando ligado e uma instrução é executada, o SQL Server apresenta as estatísticas de acesso ao cache ou buffer ou área de disco.

set statistics io on -- Ligar a apresentação
set statistics io on -- Desligar apresentação

Quais dados serão apresentados:

Para cada tabela envolvida na instrução, é apresentada uma linha com as informações de estatísticas. São elas:

- Table 'XXXXXXX'     Nome da Tabela
- Scan count          Contagem de buscas para recuperar os dados.
- logical reads       Qtd de Páginas acessadas no Buffer Pool (cache de dados).
- physical reads      Qtd de Páginas acessadas no Disco.
- read-ahead reads    Qtd de Páginas incluídas no Buffer Pool. Chamada leitura antecipada.

Outras informações contidas no resultado são referentes a dados LOB (Large Object ou tipo de dados para grandes objetos)
como varchar(max) ou varbinary(max).
São eles lob logical reads, lob physical reads e lob read-ahead reads.
LOB serão tratados em uma seção especifica.

Para mais informações e exemplos verificar



                 

