class AbandonedCartsJob < ApplicationJob
  queue_as :default

  def perform
    now = Time.current

    # Marca carrinhos como abandonados se estiverem inativos há mais de 3 horas
    Cart.where(abandoned: false)
        .where('last_interaction_at <= ?', now - 3.hours)
        .update_all(abandoned: true)

    # Remove carrinhos abandonados há mais de 7 dias
    Cart.where(abandoned: true)
        .where('last_interaction_at <= ?', now - 7.days)
        .destroy_all
  end
end