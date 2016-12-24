class Favorite< ActiveRecord::Base

  has_many :courses
  has_many :users, through: :grades

  belongs_to :user

end