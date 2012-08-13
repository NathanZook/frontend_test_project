require 'test_helper'

class PublisherSweeperTest < MiniTest::Unit::TestCase
  attr_reader :sw, :p
  def setup
    @sw = PublisherSweeper.send(:new)
    @p = Factory.build(:publisher)
  end

  def test_after_update
    ps = Object.new
    a1s = Object.new
    a2s = Object.new
    p.stub :changed?, true do
      p.stub :publishers, ps do
        p.stub :advertisers, a1s do
        Advertiser.stub(:all, lambda do |options|
          assert options == {:conditions => {:publisher_id => ps}}, "Advertiser.all called with unexpected options #{options.inspect}"
          a2s
          end
          ) do
            AdvertiserSweeper.stub :publisher_updated, lambda {|as| assert as = a1s, "Unexpected advertisers for publisher #{as.inspect}"} do
              AdvertiserSweeper.stub :publisher_parent_updated, lambda {|as| assert as = a2s, "Unexpected advertisers for publisher's publishers #{as.inspect}"} do
                sw.after_update(p)
              end
            end
          end
        end
      end
    end
  end

end
