require 'rails_helper'

RSpec.describe AbandonedCartsJob, type: :job do
  let!(:active_cart) { create(:cart, abandoned: false, last_interaction_at: 2.hours.ago) }
  let!(:inactive_cart) { create(:cart, abandoned: false, last_interaction_at: 4.hours.ago) }
  let!(:old_abandoned_cart) { create(:cart, abandoned: true, last_interaction_at: 8.days.ago) }

  it "marca carrinhos inativos há mais de 3 horas como abandonados" do
    described_class.perform_now
    expect(inactive_cart.reload.abandoned).to be true
  end

  it "não marca carrinhos ativos como abandonados" do
    described_class.perform_now
    expect(active_cart.reload.abandoned).to be false
  end

  it "remove carrinhos abandonados há mais de 7 dias" do
    expect { described_class.perform_now }.to change { Cart.count }.by(-1)
    expect { old_abandoned_cart.reload }.to raise_error(ActiveRecord::RecordNotFound)
  end
end
