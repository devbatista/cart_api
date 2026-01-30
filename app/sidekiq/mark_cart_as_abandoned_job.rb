class MarkCartAsAbandonedJob
  include Sidekiq::Job

  ABANDON_AFTER = 3.hours
  DELETE_AFTER = 7.days

  def perform
    mark_abandoned_carts
    delete_old_abandoned_carts
  end

  private

  def mark_abandoned_carts
    cutoff_time = Time.current - ABANDON_AFTER

    Cart.active
      .where('COALESCE(last_interaction_at, created_at) < ?', cutoff_time)
      .find_each(batch_size: 100) do |cart|
        cart.mark_as_abandoned!
      end
  end

  def delete_old_abandoned_carts
    cutoff_time = Time.current - DELETE_AFTER

    Cart.abandoned
      .where('abandoned_at < ?', cutoff_time)
      .find_each(batch_size: 100) do |cart|
        cart.destroy!
      end
  end
end