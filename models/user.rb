class User
  include Mongoid::Document
  include Mongoid::Timestamps

  field :first_name, :type => String
  field :last_name, :type => String
  
  validates_presence_of :first_name, :last_name

end