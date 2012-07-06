class Printing < ActiveRecord::Base
  belongs_to :book
  also_denormalize :book
end
