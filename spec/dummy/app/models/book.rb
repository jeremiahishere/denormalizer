class Book < ActiveRecord::Base
  has_many :printings

  validates_presence_of :name

  def short_name?
    name.length < 5
  end
  denormalize [:short_name?, :printed?], :class_name => "different 'class' name"

  def printed?
    !printings.empty?
  end
end
