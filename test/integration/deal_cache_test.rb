require 'test_helper'

class DealCacheTest < ActionDispatch::IntegrationTest
  include ApplicationHelper

  def setup
    @old_caching = ActionController::Base.perform_caching
    ActionController::Base.perform_caching = true

    `rm -rf #{Rails.root.join('tmp', 'cache')}`
  end

  def teardown
    `rm -rf #{Rails.root.join('tmp', 'cache')}`
    ActionController::Base.perform_caching = @old_caching
    DealSite::Application.config.serve_static_assets = @old_static_serve
  end

  def test_cache_created
    d = Factory.create(:deal)
    get '/deals'
    expect_file_for_deal(d, true, "not created")
  end

  def test_cache_not_overwritten
    d = Factory.create(:deal)
    get '/deals'
    fnames = [d, d.advertiser, nil].map{|o| cache_file_for_object(o).first}
    ftimes = fnames.map{|fn| File.mtime(fn)}
    sleep 1
    get '/deals'
    assert fnames.map{|fn| File.mtime(fn)} == ftimes
  end

  def test_cache_cleared_when_deal_updated
    d = Factory.create(:deal)
    get '/deals'
    expect_file_for_deal(d, true, "not created")

    d.price += 1
    d.save!
    expect_file_for_deal(d, false, "not cleared")
  end

  def test_cache_cleared_when_advertiser_updated
    d = Factory.create(:deal)
    get '/deals'
    expect_file_for_deal(d, true, "not created")

    a = d.advertiser
    a.name += 'x'
    a.save!
    expect_file_for_advertiser(d.advertiser, false, "not cleared")
  end

  def test_cache_cleared_when_publisher_updated
    d = Factory.create(:deal)
    get '/deals'
    expect_file_for_deal(d, true, "not created")

    p = d.advertiser.publisher
    p.name += 'x'
    p.save!
    expect_file_for_advertiser(d.advertiser, false, "not cleared")
  end

  def test_cache_cleared_when_publisher_parent_updated
    d = Factory.build(:deal)
    p = Factory.create(:publisher)
    d.advertiser.publisher.update_attributes!(parent: p)
    d.save!
    get '/deals'
    expect_file_for_deal(d, true, "not created")
    assert_template 'deals/index'
    @templates.clear

    p.name += 'x'
    p.save!
    expect_file_for_advertiser(d.advertiser, false, "not cleared")
  end


  def expect_file_for_deal(d, expect, message)
    assert cache_file_for_object(d).empty? != expect, "partial for deal #{message}"
    assert cache_file_for_object(nil).empty? != expect, "partial for index action #{message}"
    expect_file_for_advertiser(d.advertiser, expect, message) if expect
  end

  def expect_file_for_advertiser(a, expect, message)
    assert cache_file_for_object(a).empty? != expect, "partial for advertiser #{message}"
    a.deals.each{|d| expect_file_for_deal(d, expect, message)} unless expect
  end

  def cache_file_for_object(object)
    Dir.glob(Rails.root.join *%W{tmp cache * * views%2F#{cache_key('deals', 'index', object)}})
  end
end
