use DBDemo
go

drop table if exists tAluno
go

Create Table tAluno (
   Id int,                 
   Cpf char(11),           
   Nascimento datetime,    
   Nome varchar(50),       
   Endereco varchar(100),  
   Observacao varchar(100) 
)


/*
Armazenamento f�sico previs�o

   Id int,                 -- Fixo       4 bytes. 
   Cpf char(11),           -- Fixo      11 bytes. 
   Nascimento datetime,    -- Fixo       8 bytes. 
   Nome varchar(50),       -- Vari�vel  50 bytes m�ximo.
   Endereco varchar(100),  -- Vari�vel 100 bytes m�ximo. 
   Observacao varchar(100) -- Vari�vel 100 bytes m�ximo.
							         -----
						               273 bytes m�ximo.

Uma p�gina de dados tem no total 8.192 bytes.
Se 96 bytes s�o de cabe�alho, sobra 8.096 bytes.
Ent�o podemos alocar 29 linhas em uma p�gina ( 8.096/273 ). 								

O racioc�nio est� correto!

Mas temos que aprender algumas outras configura��es para entender
como esse armazenamento de linhas ocorre. 

*/


Insert Into tAluno values (
   123456,
   '12345678901',
   '1970-01-01 11:55:55' ,
   'Jose da Silva'  + replicate('A',37),
   'Av. Paulista, 100' + replicate('E', 83),
   replicate('O',100) 
)
GO 

Insert Into tAluno values (
   cast(rand()*10000 as int),
   cast( cast(rand()*100000000000 as bigint) as char(11)),
   dateadd(MINUTE,rand()*10000.0 * -24 * 60 ,getdate()) ,
   replicate('A',50),
   replicate('E', 100),
   replicate('O',100) 
)
GO 39

select sys.fn_PhysLocFormatter(%%PHYSLOC%% ) as LocalFisico, *  
  from tAluno
GO


Select *
  from sys.dm_os_buffer_descriptors
 where page_id in( 465,484) and database_id = db_id()


/*

Temos alguns fatores que contribui para que o SQL Server
armazene o maior n�mero de linhas em um p�gina, mas
as vezes esse valor � menor que esperamos. 

Um deles � como a linha � armazenada dentro de um p�gina.

Calculando tamanho da linha dentro de uma p�gina.
-------------------------------------------------
                  
- Uma linha de dados de uma tabela quando armazenada em um p�gina � definida 
  como um registro.

+---------------------------------------------------------------+
|123456123456789011970-01-0111:55:55.000Jose da SilvaAAAAAAAAA...
+---------------------------------------------------------------+

- E esses registros s�o gravados na sequ�ncia, dentro da p�gina de dados. 

------+----------------------------------------------------------------+----------------------------------------------------------------+
000...123456123456789011970-01-0111:55:55.000Jose da SilvaAAAAAAAAA....9061590231751342010-11-0308:48:31.427AAAAAAAAAAAAAAAAAAAAAAAA...|
------+----------------------------------------------------------------+----------------------------------------------------------------+

- O registro armazena os dados da linha (dados de persist�ncia) e tamb�m 
  um conjunto de bytes de controle (dados de controle ou metadados) das 
  colunas e suas caracter�sticas.

- Um registro dentro de uma p�gina ser� a sequ�ncia de "bytes de dados" e 
  "bytes de controle" intercalados. 
  
- A ordem como os dados s�o gravados dentro do registro � realizado pelo 
  SQL Server de forma a otimizar o armazenamento. Ent�o, essa ordem n�o
  respeita a ordem que as colunas foram criadas. 

- O controle da posi��o do inicial do registro dentro p�gina 
  ser� realizado pela �rea de matriz de slots.

- Uma linha recebe no m�nimo 7 bytes a mais para controle do registro dentro da 
  p�gina.

- A estrutura de um registro dentro de uma p�gina �:
+---------+---------+---------+---------+---------+---------+----------+ 
| 4 bytes | n bytes | 2 bytes | n bytes | 2 bytes | n bytes | n bytes  | 
| Header  | Fixo    | QtdCol  | NullMap | ColVar  | OffVar  | Vari�vel | 
+---------+---------+---------+---------+---------+---------+----------+ 
|         |         |         |         |         |         |- Dados de tamanho vari�vel.
|         |         |         |         |         |         |
|         |         |         |         |         |- C�lculo de deslocamento de colunas vari�vel. 
|         |         |         |         |         |  2 bytes para cada coluna.
|         |         |         |         |         |
|         |         |         |         |- Contagem de colunas de tamanho vari�vel.
|         |         |         |         |
|         |         |         |-Mapear colunas null. Mapear at� 8 colunas por byte.
|         |         |         |
|         |         |-contagem das colunas.   
|         |         |
|         |- Dados de tamanho fixo como INT, CHAR ou DATETIME por exemplo. 
|         |
|- Cabe�alho. Cont�m informa��es e caracter�sticas do Registro.


Considere ainda mais 2 bytes que ser� alocado na Matriz de Slot no
final da p�gina. Essa matriz de slot � utilizada como ponteiro de 
in�cio do registro dentro da p�gina. 

Veja abaixo uma representa��o da estrutura de um registro. 





                           P�GINA DE DADOS 
+------------------------------------------------------------------------+
|                                                                        |
|          CABE�ALHO (HEADER) DA P�GINA - 96 BYTES                       |
|                                                                        |
+------------------------------------------------------------------------+
|+---------+---------+---------+--------+---------+---------+----------+ |
|| 4 bytes | n bytes | 2 bytes | n byte | 2 bytes | n bytes | n bytes  | |
|| Header  | Fixo    | QtdCol  | NullMap| ColVar  | OffVar  | Vari�vel | |
|+---------+---------+---------+--------+---------+---------+----------+ |
|+---------+---------+---------+--------+---------+---------+----------+ |
|| 4 bytes | n bytes | 2 bytes | n byte | 2 bytes | n bytes | n bytes  | |
|| Header  | Fixo    | QtdCol  | NullMap| ColVar  | OffVar  | Vari�vel | |
|+---------+---------+---------+--------+---------+---------+----------+ |
|                                                                        |
|                                                                        |
|                                                                        |
+------------------------------------------------------------------------+
| MATRIZ DOS SLOTS                                   | 2 bytes | 2 bytes |
+------------------------------------------------------------------------+







Complexo?! No seu dia-a-dia n�o ser� necess�rio realizar esses c�lculos e nem 
ser� necess�rio examinar os registros como estamos fazendo agora.  

Mas esse entendimento ajuda a compreender como a linha � armazenada na p�gina em forma
de registro. 

Vamos ver um exemplo inserindo esse conjunto de dados:

(5555,'78654345654','1970-01-01','Jose da Silva','Av. Paulista, 100','Falta apresentar documento')

5555786543456541970-01-01Jose da SilvaAv. Paulista, 100Falta apresentar documento

Se contarmos somente os dados, temos um total de 82 caracteres.

Vamos criar uma tabela para receber esses dados.

*/

use DBDemo
go

drop table if exists tAluno
go

Create Table tAluno (
   Id int,                 -- Fixo de  4 bytes. 
   Cpf char(11),           -- Fixo de 11 bytes. 
   Nascimento datetime,    -- Fixo de  8 bytes. 
   Nome varchar(50),       -- Vari�vel de  50 bytes m�ximo.
   Endereco varchar(100),  -- Vari�vel de 100 bytes m�ximo. 
   Observacao varchar(100) -- Vari�vel de 100 bytes m�ximo.
)
go

/*
Realizando a soma somente dos bytes que ser�o utilizados para o armazenamento dos dados, temos :

Colunas de tamanho Fixo     =  23 bytes
Colunas de tamanho Vari�vel =  56 bytes, considerando os dados que ser�o armazenados.
                                         (250 bytes, considerando o armazenamento m�ximo).

No total, temos 79 bytes utilizados para armazenar 82 caracteres. 

*/

Insert Into tAluno values (5555,'78654345654','1970-01-01','Jose da Silva','Av. Paulista, 100','Falta apresentar documento')

Select * From tAluno

/*
Vamos calcular como fica o armazenamento do registro na tabela, considerando
os bytes de controle: 

|- Cabe�alho da linha.
|         |- Dados de tamanho fixo.
|         |          |- Contagem de colunas (6) 
|         |          |         |- Mapeamente de NULL das colunas.
|         |          |         |        |- Contagem de colunas vari�veis (3)
|         |          |         |        |         |- Deslocamento dos dados vari�veis.
|         |          |         |        |         |         |- Dados variav�is
|         |          |         |        |         |         |
+---------+----------+---------+--------+---------+---------+----------+----------+---------+
| 4 bytes | 23 bytes | 2 bytes | 1 byte | 2 bytes | 6 bytes | 13 bytes | 17 bytes | 26 bytes| <-- REGISTRO 
+---------+----------+---------+--------+---------+---------+----------+----------+---------+


Total de 94 bytes

Matriz de Slots 
+---------+
| 2 bytes |
+---------+
------------------
Total de 96 bytes
------------------

Observa��es:

- Voce percebeu que os dados de todas as colunas n�o ficam na ordem 
  que foram criadas!! Em uma parte do registro temos os bytes das colunas de tamanho fixo.
  Depois temos os bytes de controle e por fim temos os bytes das colunas de tamanho vari�vel. 

- Mesmo que voc� defina uma coluna de tamanho fixo como NULL e grava o NULL, 
  ela alocar� o tamanho total de armazenamento com zeros. Pelos bytes de controle
  de mapeamento de NULL, que o SQL Server sabe se a coluna retornar� o dado ou o NULL.

  
Ref.: http://aboutsqlserver.com/2013/10/15/sql-server-storage-engine-data-pages-and-data-rows/
      https://docs.microsoft.com/pt-br/sql/relational-databases/databases/estimate-the-size-of-a-database?view=sql-server-2017

*/


select sys.fn_PhysLocFormatter(%%PHYSLOC%% ) as LocalFisico, 
       tab.*
  from tAluno  as tab


select *
  from sys.dm_os_buffer_descriptors
 where page_id = 484 and database_id = db_id()



/*
Utilizar duas vis�es do cat�logo do sistemas:

sys.allocation_units		- Cont�m uma linha para cada unidade de aloca��o no banco de dados.
sys.partitions				- Cont�m uma linha para cada parti��o de todas as tabelas e para a 
                          maioria dos tipos de �ndices no banco de dados.

Ref.: 
https://docs.microsoft.com/pt-br/sql/relational-databases/system-catalog-views/sys-allocation-units-transact-sql?view=sql-server-2017
https://docs.microsoft.com/pt-br/sql/relational-databases/system-catalog-views/sys-partitions-transact-sql?view=sql-server-2017

PS: Parti��o : Recurso do SQL Server que permite dividir a tabela horizontalmente em v�rias parti��es.
               Se n�o utilizar esse recurso, a tabela � definida como um �nica parti��o. 
               
*/

select * 
  from sys.partitions pa
 where pa.object_id = object_id('tAluno')


Select pa.index_id , pa.rows  ,
       au.type, au.type_desc , au.data_space_id , au.total_pages , au.data_pages 
  From sys.partitions pa
  Join sys.allocation_units au
    on pa.partition_id  = au.container_id 
 where pa.object_id = object_id('tAluno')

/*

DMV : sys.dm_db_index_physical_stats

Retorna informa��es de tamanho e fragmenta��o dos dados. 
Para um heap, uma linha � retornada para a unidade de aloca��o de IN_ROW_DATA de cada parti��o. 

Ref.:
https://docs.microsoft.com/pt-br/sql/relational-databases/system-dynamic-management-views/sys-dm-db-index-physical-stats-transact-sql?view=sql-server-2017

*/

declare @db_id int = db_id()
declare @object_id int = object_id('tAluno')

Select index_id , 
       index_type_desc , 
	   alloc_unit_type_desc , 
	   page_count , 
	   record_count  ,
	   min_record_size_in_bytes ,
	   max_record_size_in_bytes ,
	   avg_record_size_in_bytes
  from sys.dm_db_index_physical_stats(@db_id, @object_id , null,null,'DETAILED')


go

/*
*/

use DBDemo
go

Insert Into tAluno values (5555,'78654345654','1970-01-01','Jose da Silva','Av. Paulista, 100','Falta apresentar documento')
go 10000


select * 
  from sys.partitions pa
 where pa.object_id = object_id('tAluno')

 Select pa.index_id , pa.rows  ,
       au.type, au.type_desc , au.data_space_id , au.total_pages , au.data_pages 
  From sys.partitions pa
  Join sys.allocation_units au
    on pa.partition_id  = au.container_id 
 where pa.object_id = object_id('tAluno')


declare @db_id int = db_id()
declare @object_id int = object_id('tAluno')

Select index_id , 
       index_type_desc , 
	    alloc_unit_type_desc , 
	    page_count , 
	    record_count  ,
	    min_record_size_in_bytes ,
	    max_record_size_in_bytes ,
	    avg_record_size_in_bytes
  from sys.dm_db_index_physical_stats(@db_id, @object_id , null,null,'DETAILED')
