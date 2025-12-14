# frozen_string_literal: true

class MarkCartAsAbandonedJob
  include Sidekiq::Job
  sidekiq_options retry: false

  def perform(*args)
    Cart.mark_as_abandoned
    Cart.purge_old_abandoned
  end
end
