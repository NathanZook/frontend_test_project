require 'test_helper'

class DealTest < ActiveSupport::TestCase
  test "factory should be sane" do
    assert FactoryGirl.build(:deal).valid?
  end

  # I think this is a bad test and it fails sometimes
  test "over should honor current time" do
    t0 = Time.zone.now
    Timecop.freeze t0 do
      deal = FactoryGirl.create(:deal, :end_at => t0 + 0.01)
      assert !deal.over?, "Deal should not be over"
      Timecop.freeze t0 + 0.02 do
        assert deal.over?, "Deal should be over"
      end
    end
  end
end
