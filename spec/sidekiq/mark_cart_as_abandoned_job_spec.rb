# frozen_string_literal: true

require "rails_helper"
require "sidekiq/testing"

RSpec.describe MarkCartAsAbandonedJob, type: :job do
  include ActiveJob::TestHelper

  describe "#perform" do
    let!(:active_cart) { create(:cart, status: :active, updated_at: 2.hours.ago) }
    let!(:inactive_cart) { create(:cart, status: :active, updated_at: 4.hours.ago) }
    let!(:recently_abandoned_cart) { create(:cart, status: :abandoned, abandoned_at: 6.days.ago) }
    let!(:old_abandoned_cart) { create(:cart, status: :abandoned, abandoned_at: 8.days.ago) }

    it "calls Cart.mark_as_abandoned" do
      expect(Cart).to receive(:mark_as_abandoned).once
      described_class.new.perform
    end

    it "calls Cart.purge_old_abandoned" do
      expect(Cart).to receive(:purge_old_abandoned).once
      described_class.new.perform
    end

    context "when running the job" do
      before do
        active_cart
        inactive_cart
        recently_abandoned_cart
        old_abandoned_cart

        allow(Cart).to receive(:mark_as_abandoned).and_call_original
        allow(Cart).to receive(:purge_old_abandoned).and_call_original

        described_class.new.perform
      end

      it "marks inactive carts as abandoned" do
        expect(inactive_cart.reload.status).to eq("abandoned")
        expect(inactive_cart.abandoned_at).to be_present
      end

      it "does not mark active carts as abandoned" do
        expect(active_cart.reload.status).to eq("active")
        expect(active_cart.abandoned_at).to be_nil
      end

      it "purges old abandoned carts" do
        expect(Cart.find_by(id: old_abandoned_cart.id)).to be_nil
      end

      it "does not purge recently abandoned carts" do
        expect(Cart.find_by(id: recently_abandoned_cart.id)).to be_present
      end
    end
  end
end
