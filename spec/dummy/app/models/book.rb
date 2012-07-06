class Book < ActiveRecord::Base
  has_many :printings

  validates_presence_of :name

  def short_name?
    name.length < 5
  end
  denormalize :short_name?

  def printed?
    !printings.empty?
  end
  denormalize :printed?
end
