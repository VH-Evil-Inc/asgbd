# ASGBD

![Imagem séria :)](./vhevilinc.jpg)

## Ambiente

Para esse projeto, iremos comparar o uso de uma instância única do PostgreSQL
com um deploy em cluster com o Citus. Para isso, configuramos ambientes usando
Docker Compose.

Para verificar as propriedades do escalonamento horizontal, optamos por limitar cada instância à 8GB de RAM e 2 CPUs, além de adicionar latência
aleatória de 150us +/- 200us para simular um ambiente de cloud.

Além disso, instrumentamos os deployments com Grafana e Prometheus, coletando
as métricas do PostgreSQL para podermos analisar o comportamento do sistema.

Para iniciar os ambientes, basta executar o comando (dentro da pasta `db`):

- Single: `docker compose -f ./docker-compose.std.yml up -d`
- Cluster: `docker compose -f ./docker-compose.citus-cluster.yml up -d`

Uma vez que os ambientes estão rodando, é possível acompanhar o comportamento
do sistema através do dashboard "PostgreSQL Database" no Grafana, acessível em `localhost:3000`.

Para os benchmarks, decidimos seguir com um padrão de mercado, o TPC-C, que
é um benchmark de escalabilidade de carga de processamento de transações
(também conhecido como TPC-C, TPROC-C ou TPROC-C). Além disso, também usamos o benchmark TPC-H, que é um benchmark de escalabilidade de carga de processamento de consultas (também conhecido como TPC-H ou TPROC-H). Seguimos com a implementação do HammerDB, um framework de benchmarking de carga de processamento de SQL, que é usado para testar o funcionamento de diferentes sistemas de banco de dados.

Para rodar os benchmarks, basta rodar os scirpts `run_tpcc.sh` e `run_tpch.sh`, respectivamente, dentro da pasta `db`, ou a versão para o Citus, com `run_tpcc_citus.sh` e `run_tpch_citus.sh`.

## Fazueli

- [ ] Relatório
  - [X] LaTeX
  - [X] Introdução
  - [X] Fundamentação
  - [X] Descrição do sistema proposto
  - [X] Implementação
  - [ ] Experimentos e resultados
  - [ ] Conclusões e trabalhos futuros
  - [ ] Referências
  - [ ] Apendicite
