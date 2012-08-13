module PublishersHelper
  def publisher_names(publisher)
    publisher.parent ? "#{publisher.parent.name} #{publisher.name}" : publisher.name
  end
end
