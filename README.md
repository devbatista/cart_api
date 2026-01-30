## Como rodar o projeto

### Requisitos
- Ruby 3.3.1
- PostgreSQL 16
- Redis 5+
- Node/Yarn (se for usar assets)
- Opcional: Docker + Docker Compose

### Rodando localmente (sem Docker)

```bash
bundle install
bin/rails db:prepare
bin/rails server
```

A API ficará disponível em `http://localhost:3000`.

### Rodando os testes

```bash
bundle exec rspec
```

### Sidekiq e jobs de carrinhos abandonados

Para processar jobs (incluindo o de carrinhos abandonados):

```bash
bundle exec sidekiq -C config/sidekiq.yml
```

O job `MarkCartAsAbandonedJob` é executado periodicamente de 10 em 10 minutos via `sidekiq-scheduler` e:

- Marca carrinhos como abandonados após 3 horas sem interação.
- Remove carrinhos abandonados há mais de 7 dias.