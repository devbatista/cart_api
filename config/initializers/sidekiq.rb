require 'sidekiq'
require 'sidekiq-cron'

Sidekiq::Cron::Job.create(
  name: 'Carrinhos abandonados - execução a cada hora',
  cron: '0 * * * *', # todo começo de hora
  class: 'AbandonedCartsJob'
)
