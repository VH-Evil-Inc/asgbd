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

# Citus (quantos slides desejarmos nesse mundo pra falar de tudo)

- Uau citus.
- Descrever o citus

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

# Cassandra ! (quantos slides desejarmos nesse mundo pra falar de tudo)

---

# Yahoo (YCSB)

---

# Resultados

---

# Conclusão

---

# Bibliografia
- uau documentação

---

# Perguntas!