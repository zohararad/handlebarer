Handlebarer.configure do |config|
  config.helpers_path = Rails.root.join('app','assets','javascripts','helpers')
  config.views_path = Rails.root.join('app','assets','javascripts','views')
end