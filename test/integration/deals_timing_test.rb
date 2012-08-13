require 'test_helper'

class DealTest < ActionDispatch::IntegrationTest
  def test_deals
    require './db/seeds'

    start = Time.now
    get '/deals'
    response_time = Time.now - start
    assert response_time < 0.8, "Response time too long: #{response_time}"
  end

end
