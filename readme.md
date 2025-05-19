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
do sistema através do dashboard "PostgreSQL Database" no Grafana, acessível em `localhost:3000` com o usuário `admin` e senha `admin`.

Para os benchmarks, decidimos seguir com um padrão de mercado, o TPC-C, que
é um benchmark de escalabilidade de carga de processamento de transações
(também conhecido como TPC-C, TPROC-C ou TPROC-C). Além disso, também usamos o benchmark TPC-H, que é um benchmark de escalabilidade de carga de processamento de consultas (também conhecido como TPC-H ou TPROC-H). Seguimos com a implementação do HammerDB, um framework de benchmarking de carga de processamento de SQL, que é usado para testar o funcionamento de diferentes sistemas de banco de dados.

Para rodar os benchmarks, basta rodar os scirpts `run_tpcc.sh` e `run_tpch.sh`, respectivamente, dentro da pasta `db`, ou a versão para o Citus, com `run_tpcc_citus.sh` e `run_tpch_citus.sh`.

## Resultados

Todos os testes do TPC-C foram executados com 40 warehouses e 64 virtual users.

### Standalone TPC-C

`System achieved 31405 NOPM from 72424 PostgreSQL TPM`

```
>>>>> COMBINED METRICS ACROSS ALL USERS
>>>>> PROC: PAYMENT
CALLS: 648402     MIN: 0.833ms    AVG: 52.601ms  MAX: 1257.365ms TOTAL: 34106475.135ms
P99: 413.035ms  P95: 167.278ms  P50: 27.633ms   SD: 76878.831  RATIO: 71.729%

>>>>> PROC: NEWORD
CALLS: 648063     MIN: 1.640ms    AVG: 48.569ms  MAX: 1255.893ms TOTAL: 31475935.439ms
P99: 413.374ms  P95: 160.868ms  P50: 23.915ms   SD: 78820.126  RATIO: 66.301%

>>>>> PROC: SLEV
CALLS: 65004     MIN: 0.440ms    AVG: 153.889ms  MAX: 21302.445ms TOTAL: 10003419.917ms
P99: 4235.829ms  P95: 73.669ms  P50: 6.215ms   SD: 1402535.846  RATIO: 21.014%

>>>>> PROC: DELIVERY
CALLS: 64713     MIN: 1.278ms    AVG: 54.623ms  MAX: 1417.772ms TOTAL: 3534810.624ms
P99: 441.496ms  P95: 191.119ms  P50: 25.470ms   SD: 85934.701  RATIO: 7.448%

>>>>> PROC: OSTAT
CALLS: 63558     MIN: 0.104ms    AVG: 2.725ms  MAX: 455.587ms TOTAL: 173186.360ms
P99: 47.199ms  P95: 3.844ms  P50: 1.292ms   SD: 9232.670  RATIO: 0.365%
```

### Cluster TPC-C

`System achieved 15304 NOPM from 35762 PostgreSQL TPM`

```
>>>>> PROC: PAYMENT
CALLS: 357969     MIN: 0.990ms    AVG: 101.086ms  MAX: 1767.711ms TOTAL: 36185664.966ms
P99: 611.674ms  P95: 352.694ms  P50: 72.123ms   SD: 124203.689  RATIO: 73.732%

>>>>> PROC: NEWORD
CALLS: 358992     MIN: 1.774ms    AVG: 107.871ms  MAX: 1737.546ms TOTAL: 38724729.750ms
P99: 607.420ms  P95: 362.191ms  P50: 83.081ms   SD: 123040.591  RATIO: 79.003%

>>>>> PROC: DELIVERY
CALLS: 35715     MIN: 2.286ms    AVG: 115.989ms  MAX: 1505.085ms TOTAL: 4142561.285ms
P99: 596.206ms  P95: 375.478ms  P50: 90.453ms   SD: 125203.863  RATIO: 8.462%

>>>>> PROC: SLEV
CALLS: 36069     MIN: 0.612ms    AVG: 63.438ms  MAX: 5600.833ms TOTAL: 2288143.726ms
P99: 730.162ms  P95: 224.685ms  P50: 8.710ms   SD: 221772.540  RATIO: 4.667%

>>>>> PROC: OSTAT
CALLS: 35067     MIN: 0.269ms    AVG: 7.474ms  MAX: 609.841ms TOTAL: 262082.364ms
P99: 80.547ms  P95: 60.180ms  P50: 2.439ms   SD: 18430.345  RATIO: 0.536%
```
