class User < ActiveRecord::Base
  include Handlebarer::Serialize
  hbs_serializable :name, :email
end