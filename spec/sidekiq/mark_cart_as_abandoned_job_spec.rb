require 'rails_helper'

RSpec.describe MarkCartAsAbandonedJob, type: :job do
  it 'marca como abandonados os carrinhos inativos há mais de 3 horas' do
    cart = Cart.create!(
      total_price: 0,
      abandoned: false,
      last_interaction_at: 4.hours.ago
    )

    MarkCartAsAbandonedJob.new.perform

    cart.reload
    expect(cart.abandoned).to eq(true)
    expect(cart.abandoned_at).to be_present
  end

  it 'não marca como abandonados carrinhos recentes' do
    cart = Cart.create!(
      total_price: 0,
      abandoned: false,
      last_interaction_at: 1.hour.ago
    )

    MarkCartAsAbandonedJob.new.perform

    cart.reload
    expect(cart.abandoned).to eq(false)
    expect(cart.abandoned_at).to be_nil
  end

  it 'remove carrinhos abandonados há mais de 7 dias' do
    cart = Cart.create!(
      total_price: 0,
      abandoned: true,
      abandoned_at: 8.days.ago
    )

    expect {
      MarkCartAsAbandonedJob.new.perform
    }.to change { Cart.exists?(cart.id) }.from(true).to(false)
  end

  it 'usa created_at quando last_interaction_at é nulo' do
    cart = Cart.create!(
      total_price: 0,
      abandoned: false,
      last_interaction_at: nil,
      created_at: 4.hours.ago
    )

    MarkCartAsAbandonedJob.new.perform

    cart.reload
    expect(cart.abandoned).to eq(true)
    expect(cart.abandoned_at).to be_present
  end

  it 'não deleta carrinhos ativos mesmo que antigos' do
    cart = Cart.create!(
      total_price: 0,
      abandoned: false,
      last_interaction_at: 10.days.ago
    )

    expect {
      MarkCartAsAbandonedJob.new.perform
    }.not_to change { Cart.exists?(cart.id) }
  end

  it 'não deleta carrinhos abandonados há menos de 7 dias' do
    cart = Cart.create!(
      total_price: 0,
      abandoned: true,
      abandoned_at: 3.days.ago
    )

    expect {
      MarkCartAsAbandonedJob.new.perform
    }.not_to change { Cart.exists?(cart.id) }
  end

  it 'é idempotente ao marcar como abandonado' do
    cart = Cart.create!(
      total_price: 0,
      abandoned: false,
      last_interaction_at: 4.hours.ago
    )

    2.times { MarkCartAsAbandonedJob.new.perform }

    cart.reload
    expect(cart.abandoned).to eq(true)
  end
end