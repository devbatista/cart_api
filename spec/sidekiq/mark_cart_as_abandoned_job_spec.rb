require 'rails_helper'

RSpec.describe MarkCartAsAbandonedJob, type: :job do
  it 'marks carts inactive for more than 3 hours as abandoned' do
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

  it 'does not mark recent carts as abandoned' do
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

  it 'removes carts abandoned for more than 7 days' do
    cart = Cart.create!(
      total_price: 0,
      abandoned: true,
      abandoned_at: 8.days.ago
    )

    expect {
      MarkCartAsAbandonedJob.new.perform
    }.to change { Cart.exists?(cart.id) }.from(true).to(false)
  end

  it 'uses created_at when last_interaction_at is nil' do
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

  it 'does not delete active carts even if old' do
    cart = Cart.create!(
      total_price: 0,
      abandoned: false,
      last_interaction_at: 10.days.ago
    )

    expect {
      MarkCartAsAbandonedJob.new.perform
    }.not_to change { Cart.exists?(cart.id) }
  end

  it 'does not delete carts abandoned for less than 7 days' do
    cart = Cart.create!(
      total_price: 0,
      abandoned: true,
      abandoned_at: 3.days.ago
    )

    expect {
      MarkCartAsAbandonedJob.new.perform
    }.not_to change { Cart.exists?(cart.id) }
  end

  it 'is idempotent when marking as abandoned' do
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