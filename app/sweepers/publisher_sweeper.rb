class PublisherSweeper < ActionController::Caching::Sweeper
  observe Publisher

  def after_update(publisher)
    return unless publisher.changed?

    AdvertiserSweeper.publisher_updated(publisher.advertisers)
    AdvertiserSweeper.publisher_parent_updated(Advertiser.all(:conditions => {:publisher_id => publisher.publishers}))
  end
end
