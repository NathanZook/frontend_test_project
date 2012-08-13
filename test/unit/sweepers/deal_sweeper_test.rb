require 'test_helper'

class DealSweeperTest < MiniTest::Unit::TestCase
  attr_reader :ds, :d, :c, :index_key, :d_key
  def setup
    @ds = DealSweeper.send(:new)
    @d = Factory.build(:deal, :id => 5)
    @c = Minitest::Mock.new

    @index_key = 'deals__index'
    @d_key = "deals__index__Deal#{d.id}"
  end

  def teardown
    assert c.verify
    Advertiser.delete_all
    Publisher.delete_all
  end

  # Note: we are not testing DealSweeper#controller, as mocking
  # ActiveController::Base.new pollutes the class.  Don't ask me how.

  # Same problem for DealSweeper.advertiser_updated

  def test_after_create
    c.expect(:expire_fragment, nil, [index_key])
    ds.stub :controller, c do
      ds.after_create(d)
    end
  end

  def test_after_destroy
    c.expect(:expire_fragment, nil, [d_key])
    c.expect(:expire_fragment, nil, [index_key])
    ds.stub :controller, c do
      ds.after_destroy(d)
    end
  end

  def test_after_update_with_change
    c.expect(:expire_fragment, nil, [d_key])
    c.expect(:expire_fragment, nil, [index_key])
    ds.stub :controller, c do
      d.stub :changed?, true do
        ds.after_update(d)
      end
    end
  end

  def test_after_update_no_change
    d.stub :changed?, false do
      ds.after_update(d)
    end
  end

  def test_updated
    d2 = Factory.build(:deal, :id => 21)
    d2_key = "deals__index__Deal#{d2.id}"
    c.expect(:expire_fragment, nil, [d_key])
    c.expect(:expire_fragment, nil, [d2_key])
    c.expect(:expire_fragment, nil, [index_key])

    ds.stub :controller, c do
      ds.updated([d, d2])
    end
  end

  def test_updated_no_deals
    ds.stub :controller, c do
      ds.updated([])
    end
  end
end
