/*
Explica��o.

A tabela DemoPage � uma Heap Table. Uma tabela que n�o tem �ndices clusterizado.

Como ela n�o tem �ndices para a coluna iIDCliente = 1, o SQL Server
precisar ler toda as p�ginas da tabela para encontrar a linha que
satisfa��o o predicado.

Mesmo que voce inclua os dados em uma ordem que deseja que eles fiquem, 
uma Heap Table n�o tem em sua estrutura os dados algo que indique que esses dados
est�o ordenados.

Por isso que sempre uma pesquisa de dados ler�o todas as p�ginas da tabela heap.

Quando utilizar uma Heap Table?

Tabelas pequenas com poucas linhas e colunas cuja a soma total de bytes que ser�o
armazenados for menor que 8060 bytes.

Ref.: https://docs.microsoft.com/pt-br/sql/relational-databases/indexes/heaps-tables-without-clustered-indexes

*/ 
