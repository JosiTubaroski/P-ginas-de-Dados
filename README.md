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

Para mais informações e verificar exemplos 

https://github.com/JosiTubaroski/P-ginas-de-Dados/blob/main/01%20-%20Estrutura%20de%20uma%20pagina%20de%20dados.sql

### 02 - O que é uma Heap Table

Explicação

A tabela DemoPage é uma Heap Table. Uma tabela que não tem índices clusterizado.

Como ela não tem índices para a coluna iDCliente = 1, o SQL Server precisa ler toda a página da tabela para encontrar a linha que satisfaça o predicado.

Mesmo que voce inclua os dados em uma ordem que deseja que eles fiquem, uma Heap Table não tem em sua estrutura algo que indique que esses dados estão ordenados.

Por isso que sempre uma pesquisa de dados lerão todas as páginas da tabela heap.

Quando utilizar uma Heap Table?

Tabelas pequenas com poucas linhas e colunas cuja a soma total de bytes que serão armazenados for menor que 8060 bytes.

Ref.: https://docs.microsoft.com/pt-br/sql/relational-databases/indexes/heaps-tables-without-clustered-indexes

### 03 - Localizando uma linha na página.

Como sei que uma determinada linha ou dados estão em uma página?

No SQL Server, podemos utilizar de algumas formas para identificar a página de dados de uma linha ou as linhas contidas em uma página de dados.

Uma delas é usando a pseudo coluna %%PHYSLOC%% que retorna um hexadecimal com o RID ( ROW IDENTIFIER ) do endereço físico da linha dentro de uma página.

Ref.: http://sqlity.net/en/2451/physloc/
      https://www.sqlskills.com/blogs/paul/sql-server-2008-new-undocumented-physical-row-locator-function/

Para saber mais verificar:

https://github.com/JosiTubaroski/P-ginas-de-Dados/blob/main/03%20-%20Localizando%20uma%20linha%20na%20p%C3%A1gina.sql

### 04 - O que é um extend

O que são os Extends ou Extensões

----------------------------------------

Extend ou Extensão são agrupamentos de 8 páginas de dados fisicamente contíguas

Um Extend tem o tamanho de 64Kb.

O objetivo é gerenciar melhor o armazenamento físico dos dados.

Para saber mais verificar:

https://github.com/JosiTubaroski/P-ginas-de-Dados/blob/main/04%20-%20Estrutura%20de%20um%20Extent.sql




      




                 

