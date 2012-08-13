require 'test_helper'

class PublisherTest < ActiveSupport::TestCase
  test "can't have self as parent" do
    publisher = FactoryGirl.create(:publisher)
    assert publisher.valid?

    publisher.parent = publisher
    assert !publisher.valid?

    second_publisher = FactoryGirl.create(:publisher)
    publisher.parent = second_publisher
    assert publisher.valid?

    publisher.save!
  end

  test "get_theme when own theme" do
    publisher = FactoryGirl.create(:publisher, theme: 'abc')
    assert publisher.get_theme == publisher.theme
  end

  test "get_theme when no theme, but ancestor does have theme" do
    granddaddy = FactoryGirl.create(:publisher, theme: 'jkl')
    p1 = FactoryGirl.create(:publisher, theme: nil, parent: granddaddy)
    p2 = FactoryGirl.create(:publisher, theme: nil, parent: p1)
    p3 = FactoryGirl.create(:publisher, theme: nil, parent: p2)
    p4 = FactoryGirl.create(:publisher, theme: nil, parent: p3)

    assert p2.get_theme == granddaddy.theme
    assert p3.get_theme == granddaddy.theme
    assert p1.get_theme == granddaddy.theme
    assert p4.get_theme == granddaddy.theme
  end

  test "get_them when no theme" do
    publisher = FactoryGirl.create(:publisher, theme: nil)
    assert publisher.get_theme == nil
  end
end
