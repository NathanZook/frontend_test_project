class PublisherThemeDryer < ActiveRecord::Migration
  def up
    entertainment = Publisher.find_by_name('Entertainment')
    Publisher.update_all({theme: nil}, {parent_id: entertainment})
  end

  def down
    entertainment = Publisher.find_by_name('Entertainment')
    theme_map = {"Boston"=>"boston", "New York"=>"new-york", "Chicago"=>"chicago", "Portland"=>"pdx"}
    entertainment.publishers.each{|p| p.update_attributes!(theme: "entertainment-#{theme_map[p.name]}")}
  end
end
