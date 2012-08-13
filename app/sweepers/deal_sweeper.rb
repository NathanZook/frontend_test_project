class DealSweeper < ActionController::Caching::Sweeper
  include ApplicationHelper
  observe Deal

  def controller
    @controller ||= ActionController::Base.new
  end

  def after_create(deal)
    controller.expire_fragment(cache_key('deals', 'index', nil))
  end

  def after_destroy(deal)
    updated([deal])
  end

  def after_update(deal)
    return unless deal.changed?
    updated([deal])
  end

  def updated(deals)
    return if deals.empty?

    deals.each{|deal| controller.expire_fragment(cache_key('deals', 'index', deal))}
    after_create(deals.first)
  end

  class << self
    def advertiser_updated(deals)
      new.updated(deals)
    end
  end
end
