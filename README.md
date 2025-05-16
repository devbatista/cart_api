# Carrinho API

API REST em Ruby on Rails para gerenciamento de carrinho de compras como parte de um desafio técnico RD Station.

## Requisitos

| Dependência | Versão |
|-------------|--------|
| Ruby        | 3.3.1 |
| Rails       | 7.1.3.2 |
| PostgreSQL  | 16 |
| Redis       | 7.0.15 |

## Instalação local

```bash
git clone git@github.com:devbatista/cart_api.git
cd cart_api
bundle install
rails db:create db:migrate
redis-server
bundle exec sidekiq
rails server
```

## Docker

```bash
docker-compose build
docker-compose run web rails db:create db:migrate
docker-compose up
```

## Endpoints

| Método & Rota          | Descrição                              |
|------------------------|----------------------------------------|
| `POST /cart`           | Adiciona produto ao carrinho           |
| `GET /cart`            | Lista itens do carrinho                |
| `PATCH /cart/add_item` | Altera quantidade de item              |
| `DELETE /cart/:id`     | Remove item do carrinho                |

### Exemplo `POST /cart`

```json
POST /cart
{
  "product_id": 1,
  "quantity": 2
}
```

### Resposta

```json
{
  "id": 10,
  "products": [
    {
      "id": 1,
      "name": "Produto X",
      "quantity": 2,
      "unit_price": 7.00,
      "total_price": 14.00
    }
  ],
  "total_price": 14.00
}
```

## Job de Carrinhos Abandonados

- Marca carrinhos sem interação > 3h como `abandoned`.
- Remove carrinhos abandonados há > 7 dias.
- Agendado a cada hora usando **sidekiq-cron**.

## Testes

```bash
bundle exec rspec
```

Cobertura:

- Models (`Product`, `Cart`, `CartItem`)
- Request specs (`CartsController`)
- Job specs (`AbandonedCartsJob`)

## Estrutura

```
app/
  controllers/
  models/
  jobs/
  serializers/
config/
spec/
```

## Decisões Técnicas

- **Header `X-Cart-Id`** para identificar carrinho e facilitar testes.
- Preço unitário salvo no `CartItem` para manter histórico.
- `Sidekiq` + `Redis` para processamento assíncrono.
