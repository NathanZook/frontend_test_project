class AdvertiserSweeper < ActionController::Caching::Sweeper
  include ApplicationHelper
  observe Advertiser

  def controller
    @controller ||= ActionController::Base.new
  end

  def after_update(advertiser)
    return unless advertiser.changed?

    updated([advertiser])
  end

  def updated(advertisers)
    return if advertisers.empty?

    advertisers.each{|advertiser| controller.expire_fragment(cache_key('deals', 'index', advertiser))}
    DealSweeper.advertiser_updated(Deal.all(:conditions => {:advertiser_id => advertisers}))
  end

  class << self

    def publisher_updated(advertisers)
      new.updated(advertisers)
    end

    alias_method :publisher_parent_updated, :publisher_updated
  end
end

