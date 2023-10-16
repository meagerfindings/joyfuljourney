class User < ApplicationRecord
  attr_reader :name

  validates :first_name, presence: true
  validates :last_name, presence: true

  has_many :post

  def name
    "#{first_name} #{last_name}"
  end
end

