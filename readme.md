# ASGBD

![Imagem séria :)](./vhevilinc.jpg)

## Fazueli

- [ ] Setar os ambientes locais (docker-compose)
  - [ ] Sharded
  - [ ] Replicado
  - [ ] Standalone
- [ ] Comparar estratégias
  - [ ] Diferentes configurações Citus?
  - [ ] Sharding manual?
  - [ ] Outro caminho de replicação (pg_auto_failover)?
  - [ ] Comparar impactos de latência (diferentes ambientes)
  - [ ] Comparar impactos nos custos de sincronização (locks)
- [ ] Preparar o carregamento dos datasets
  - [ ] Schema / DDL
  - [ ] Script de carregamento $(\text{Python} + \text{Rust})^{\text{Polars}}$
- [ ] Desenvolver serviços básicos
  - [ ] CRUD :)
  - [ ] Algumas queries mais complexas de agregação
- [ ] Desenvolver benchmarks
- [ ] Instrumentação (telemetria)
  - [ ] Prometheus
  - [ ] Grafana
  - [ ] PostgreSQL (<https://github.com/prometheus-community/postgres_exporter>)
  - [ ] Serviços (<https://github.com/open-telemetry/opentelemetry-rust>)
- [ ] Relatório
  - [X] LaTeX :D (dica: usar tectonic) ~~ou **MD + Pandoc**~~
  - [ ] Introdução
  - [ ] Fundamentação teórica (**boooooooooriiiiiiiiing**)
  - [ ] Descrição do sistema proposto
  - [ ] Implenmtação
  - [ ] Experimentos e resultados
  - [ ] Conclusões e trabalhos futuros
  - [ ] Referências
  - [ ] Apendicite


