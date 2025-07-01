---
marp: true
theme: copernicus
paginate: true
---

<!-- _class: titlepage -->

![bg left:33% saturate:1.5](assets/cassandra_painting.jpg)

<div class="title"> Comparativo entre bases de dados distribuídas SQL e NoSQL </div>
<div class="subtitle"      > Análises e resultados de sistemas e estratégias </div>
<br>
<div class="author"        > Lívia Lelis 12543822 </div>
<div class="author"        > Lourenço de Salles Roselino 11796805 </div>
<div class="author"        > Samuel Figueiredo Veronez 12542626 </div>
<div class="date"          > SCC0243 - Arquitetura de Sistemas Gerenciadores de Base de Dados </div>
<div class="organization"  > São Carlos - SP | 1°Semestre 2025 ICMC-USP </div>



---

# Introdução & Motivação

Tendo em vista a demanda crescente por sistemas eficientes e robustos para dados este trabalho foi desenvolvido para avaliar a performance e overhead entre diferentes sistemas gerenciadores de base de dados, distribuídos e centralizados.

Este trabalho não visa fazer uma comparação direta entre a performance individual de cada SGBD e sim estudar e entender suas técnicas de distribuição e comparar seus escalonamentos horizontais.

---

# Conceitos para Bases de Dados Distribuídas

- Fragmentação
    - Horizontal
    - Vertical
    - Mista
- Replicação
- Homogenidade e Heterogenidade
- Alocação de dados

---

<!-- _class: transition -->

![bg opacity:.08 blur:2.0px grayscale:1 brightness:0.75](https://github.com/VH-Evil-Inc/asgbd/blob/main/vhevilinc.jpg?raw=true)

# PostgreSQL & Citus

---

# Arquitetura usada na parte de psql

---

# Citus

Citus é uma extensão do PostgreSQL para bancos de dados distribuídos. O Citus apresenta suporte à fragmentação horizontal, fragmentação por esquema e replicação de dados. 

---

<center>

# Modelos de fragmentação

</center>

<div class="columns">
<div>

## Fragmentação Horizontal

Um único esquema é utilizado entre todos os nós, tendo a fragmentação feita por tuplas que tem seu nó de residência determinado por uma coluna de distribuição.

</div>

<div>

## Fragmentação por Esquema

Permite diferentes nós usarem diferentes esquemas, ainda permite tabelas compartilhadas e outras funcionalidades do Citus em esquemas não fragmentados.

</div>
</div>

---

<div class="columns">
<div>


![h:400 drop-shadow:4px,5px,15px,#010101](./assets/citus-architecture.png)

<figcaption align="center">
<b>Figura</b>: Arquitetura coordinator-worker do Citus. Obtido em: https://github.com/citusdata/citus#Architecture
</figcaption>


</div>
<div> 

- Dois tipos de nós: worker e coordinator

- Worker armazenam os dados das tabelas distribuidas e processam as consultas
- Cada coordinator node gerencia um cluster de worker nodes 
    - Faz o intermédio das consultas da aplicação entre um ou múltiplos nós, acumulando e retornando os resultados para a aplicação
    - Também também mantém a alocação, o controle da consistência dos dados e da integridade dos nós trabalhadores.
</div>
<div>

---

<center>

# Tipos de Tabelas

</center>

<div class="columns3">
<div>

### Tabelas distribuídas

Tabelas com os dados particionados e distribuídos entre vários nós trabalhadores, permitindo consultas e operações paralelas.

</div>

<div>

### Tabelas de referência

São tabelas replicadas em todos os nós trabalhadores, utilizadas para armazenar dados pequenos e frequentemente acessados.

</div>

<div>

### Tabelas locais

São tabelas que existem apenas no nó coordenador e não são distribuídas nem replicadas. 

</div>

</div>

---

<div class="columns">
<div>

<center>

![h:400 drop-shadow:4px,5px,15px,#010101](./assets/ch3-2.png)

<figcaption align="center">
<b>Figura</b>: Esquema relacionado do TPC-C. Obtido em: https://www.hammerdb.com/docs3.3/ch03s05.html
</figcaption>

</center>

</div>
<div> 
<center> TCP-C ! :) </center>
</div>
<div>

---

# Estratégia de Distribuição

```sql
-- Distribution Configuration
SELECT create_reference_table('warehouse');
SELECT create_reference_table('district');
SELECT create_reference_table('item');

SELECT create_distributed_table('customer', 'c_w_id', colocate_with => 'none');
SELECT create_distributed_table('stock', 's_w_id', colocate_with => 'customer');
SELECT create_distributed_table('orders', 'o_w_id', colocate_with => 'customer');
SELECT create_distributed_table('new_order', 'no_w_id', colocate_with => 'customer');
SELECT create_distributed_table('order_line', 'ol_w_id', colocate_with => 'customer');
SELECT create_distributed_table('history', 'h_w_id', colocate_with => 'customer');
```

---

# Resultados

---

<!-- _class: transition -->

![bg opacity:.08 blur:2.0px grayscale:1 brightness:0.75](./assets/cassandra_eye.png)

# Cassandra 👁

---

# Arquitetura usada na parte de nosql

---

# Talvez falar sobre Wide Column ?

---

# Cassandra 

Apache Cassandra é um banco de dados _open-source_ NoSQL distribuído, sendo classificado como um _Wide-Column Database_.

---

# Cassandra

Cassandra utiliza uma arquitetura _masterless_ com _clusters_ organizados em forma de anel, todos os nós do Cassandra podem responder a aplicação e comunicar com todos os outros nós dentro de um anel.

<center>

![h:400 drop-shadow:4px,5px,15px,#010101](./assets/apache-cassandra-diagrams-01.jpg)

</center>

---

# Estrutura de Dados e Particionamento

Os dados no cassandra são organizados em keyspaces que agrupam tabelas relacionadas. Cada tabela é composta por linhas e colunas 

Cada linha é identificada por uma chave primária composta por um partition key e, opcionalmente, colunas de ordenação (clustering columns)

A distribuição dos dados é feita de forma que cada nó do cluster seja responsável por um intervalo do espaço de tokens. 

---

# Replicação e Tolerância a Falhas

Cassandra implementa replicação configurável por _keyspace_, permitindo definir o fator de replicação e a estratégia de replicação mais adequada ao ambiente. 

---

# Consistência

O Cassandra possui _tunable consistency_, permitindo o usuário definir por operação quantos nós precisam confirmar uma leitura ou escrita para que ela seja bem-sucedida.

Isso permite ajustar entre priorizar consistência forte ou disponibilidade, conforme a necessidade da aplicação. 

Por padrão o Cassandra opera como um sistema _AP_ (alta disponibilidade e tolerância a partições), mas pode ser configurado para comportar-se como _CP_(consistência e tolerância a partições) em cenários específicos.

---

# Yahoo! Cloud Serving Benchmarking (YCSB)

---

# Resultados

---

# Conclusão

---

# Bibliografia
- uau documentação

---

# Perguntas!