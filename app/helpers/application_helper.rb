module ApplicationHelper
  def cache_key(controller, view, object)
    object ? '%s__%s__%s%d' % [controller, view, object.class, object.id] : '%s__%s' % [controller, view]
  end
end
