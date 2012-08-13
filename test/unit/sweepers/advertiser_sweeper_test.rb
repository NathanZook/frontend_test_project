require 'test_helper'

class AdvertiserSweeperTest < MiniTest::Unit::TestCase
  attr_reader :as, :a, :c, :index_key, :a_key
  def setup
    @as = AdvertiserSweeper.send(:new)
    @a = Factory.build(:advertiser, :id => 8)
    @c = Minitest::Mock.new

    @index_key = 'deals__index'
    @a_key = "deals__index__Advertiser#{a.id}"
  end

  def teardown
    assert c.verify
    Publisher.delete_all
  end

  # Note: we are not testing DealSweeper#controller, as mocking
  # ActiveController::Base.new pollutes the class.  Don't ask me how.

  # Same problem for DealSweeper.publisher_updated

  def test_after_update
    c.expect(:expire_fragment, nil, [a_key])
    results = Object.new
    a.stub :changed?, true do
      as.stub :controller, c do
        Deal.stub(:all, lambda do |options|
          assert options == {:conditions => {:advertiser_id => [a]}}, "Deal.all called with unexpected options #{options.inspect}"
          results
          end
          ) do
          DealSweeper.stub(:advertiser_updated, lambda{|deals| assert deals == results, "Results not forwarded"}) do
            as.after_update(a)
          end
        end
      end
    end
  end

  def test_after_update_no_change
    a.stub :changed?, false do
      as.stub :controller, c do
        as.after_update(a)
      end
    end
  end

  def test_updated
    a2 = Factory.build(:advertiser, :id => 34)
    a2_key = "deals__index__Advertiser#{a2.id}"
    c.expect(:expire_fragment, nil, [a_key])
    c.expect(:expire_fragment, nil, [a2_key])
    results = Object.new

    as.stub :controller, c do
      Deal.stub(:all, lambda do |options|
        assert options == {:conditions => {:advertiser_id => [a, a2]}}, "Unexpected options #{options.inspect}"
        results
        end
        ) do
        DealSweeper.stub(:advertiser_updated, lambda{|deals| assert deals == results, "Results not forwarded"}) do
          as.updated([a, a2])
        end
      end
    end
  end

  def test_updated_no_advertisers
    as.stub :controller, c do
      as.updated([])
    end
  end

end
