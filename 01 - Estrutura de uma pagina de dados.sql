/*

P�GINA DE DADOS - 8Kb ou 8192 bytes 

+-----------------------------------------------------------+
|                                                           |
|          CABE�ALHO (HEADER) DA P�GINA - 96 BYTES          |
|                                                           |
+-----------------------------------------------------------+
|                                                           |
|                       �REA DE DADOS                       | 
|                                                           |
|         TAMANHO M�XIMO DE UMA LINHA : 8060 BYTES          |
|                                                           |
|                                                           |
|                                                           |
+-----------------------------------------------------------+
| MATRIZ DOS SLOTS - 2 BYTES POR LINHA             |  |  |  |
+-----------------------------------------------------------+

Uma p�gina de dados � exclusiva de um objeto de aloca��o de dados (Tabela ou �ndice). 

Cabe�alho      : ID da P�gina, ID do Objeto, Tipo da P�gina, espa�o live, etc....
�rea de Dados  : Onde as linhas ser�o armazenadas. Alocadas em s�rie, a partir do final do 
                 cabe�alho. Cada linha tem o limite de 8060 bytes. 
Matriz de Slot : Uma tabela que cont�m para cada linha, a posi��o que ele se inicia dentro da 
                 p�gina. Tamb�m conhecida como tabela de deslocamento de linha ou offset row. 

Considerando a �rea de dados e matriz de slots, temos 8.096 bytes para armazenamento.

Ref.: 
https://docs.microsoft.com/pt-br/sql/relational-databases/pages-and-extents-architecture-guide

*/


/*
Set statistics io 


Quando ligado e uma instru��o � executada, o SQL Server apresenta as estat�sticas 
de acesso ao cache ou buffer ou a �rea de disco.

set statistics io on -- Ligar a apresenta��o
set statistics io off -- Desligar a apresenta��o

*/

set statistics io on

set statistics io off

/*
Quais dados s�o apresentados: 

Para cada tabela envolvida na instru��o, � apresenta uma linha 
com as informa��es de estat�sticas. S�o elas:

Table 'XXXXXXXX'		Nome da Tabela 
Scan count           Contagem de buscas para recuperar os dados.
logical reads			Qtd de P�ginas acessadas no Buffer Pool (cache de dados).
physical reads       Qtd de P�ginas acessadas do Disco.
read-ahead reads		Qtd de P�ginas inclu�das no Buffer Pool. Chamda leitura antecipada.

Outras informa��es contidas no resultado s�o referentes a dados LOB (Large Object ou 
tipo de dados para grandes objetos) como varchar(max) ou varbinary(max). 
S�o eles lob logical reads, lob physical reads e lob read-ahead reads. 
LOB ser�o tratados em uma se��o espec�fica.
*/

use DBDemo
go

Drop Table if exists DemoPage
go

Create Table DemoPage 
(
   Id int, 
   Titulo char(1000), 
   Observacao char(3000)
) 

/*
Cada linha da tabela ter� cerca de 4004 bytes.
Vamos usar a fun��o REPLICATE para criar uma senten�a de caracters e incluir nas colunas.
*/

set statistics io on 

-- Primeira inclus�o.

Insert into DemoPage (id, Titulo, Observacao) 
Values (1,replicate('A',1000),replicate('A',3000))

/*
Table 'DemoPage'. Scan count 0, logical reads 1, physical reads 0, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.

Scan count = 0, n�o fez busca para recuperar dados.
Logical Reads = 1, leu uma p�gina para gravar os dados.
*/

Select * from DemoPage 

/*
Table 'DemoPage'. Scan count 1, logical reads 1, physical reads 0, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.
Scan count = 1, fez uma busca na tabela para recuperar dados.
Logical Reads = 1, leu uma p�gina para gravar os dados.
*/


-- Segunda Inclus�o 
Insert into DemoPage (id, Titulo, Observacao) 
Values (2,replicate('B',1000),replicate('B',3000))

/*
Table 'DemoPage'. Scan count 0, logical reads 1, physical reads 0, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.
*/

Select * from DemoPage


-- Terceira Inclus�o 
Insert into DemoPage (id, Titulo, Observacao) 
Values (3,replicate('C',1000),replicate('C',3000))


Select * from DemoPage

/*
id          titulo                                            
----------- --------------------------------------------------...
1           AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA...
1           BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB...
1           CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC...

(3 rows affected)

Table 'DemoPage'. Scan count 1, logical reads 2, physical reads 0, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.
*/

Select * 
  From DemoPage 
 where id = 1


Update DemoPage 
   set Titulo = replicate('a',1000)
 where id = 1 

/*
Para ler uma linha que est� em uma p�gina, ele leu 2 p�ginas de dados ?
*/


/*
*/

use DBDemo
go

set statistics io off


Drop table if exists tCliente 

/*
Cria uma tabela  
*/

Select iIDCliente, iIDEstado, cNome, cCPF, cEmail, 
       cCelular, dCadastro, dNascimento, cLogradouro, 
       cCidade, cUF, cCEP,  dDesativacao, mCredito 
  Into tCliente 
  From eCommerce.dbo.tCliente 

/*
Carregando uma linha da tabela clientes 
*/
set statistics io on

Select * 
  From tCliente
 Where iIDCliente = 1 

/*
Resultado :

iIDCliente  iIDEstado   cNome                 cCPF           cEmail                      cCelular    dCadastro  dNascimento cLogradouro        cCidade  cUF  cCEP     dDesativacao mCredito
----------- ----------- --------------------- -------------- --------------------------- ----------- ---------- ----------- ------------------ -------- ---- -------- ------------ ---------------------
1           1           Lara Moran Shepherd   1608122228599  eget.ipsum@loremsemper.com  67460 9064  2001-02-15 1971-09-18  524-4351 Ante Rd.  Itabuna  BA   43660387 NULL         100000,00

11Lara Moran Shepherd1608122228599eget.ipsum@loremsemper.com67460 90642001-02-151971-09-18524-4351 Ante Rd.ItabunaBA43660387NULL100000,00
----------------------------------------------------------------------------------------------------------------------------------------- 
138 bytes 

(1 row affected)

Table 'tCliente'. Scan count 1, logical reads 4016, physical reads 0, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.

Logical Reads 4016, foram lidas 32 MB (?!?)

*/

Select * from tCliente

/*
(200000 rows affected)
Table 'tCliente'. Scan count 1, logical reads 4016, physical reads 0, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.

Para ler um linha, logical reads 4016
Para ler todas as linhas, logical reads 4016 (???)
