require 'test_helper'

class ApplicationHelperTest < ActionView::TestCase
  attr_reader :v

  def setup
    @v = Object.new
    v.extend ApplicationHelper
  end

  def test_cache_key_with_null
    key = v.cache_key('controller', 'action', nil)
    assert key == 'controller__action', "Unexpected key #{key}"
  end

  def test_cache_key_with_object
    o = Object.new
    class << o ; def id ; 13 ; end ; end
    key = v.cache_key('c2', 'a2', o)
    assert key == 'c2__a2__Object13', "Unexpected key #{key}"
  end
end
