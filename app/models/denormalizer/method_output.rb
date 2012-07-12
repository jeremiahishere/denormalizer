class Denormalizer::MethodOutput < ActiveRecord::Base
  set_table_name "denormalizer_method_outputs"

  belongs_to :denormalized_object, :polymorphic => true
  validates_presence_of :denormalized_object_type, :denormalized_object_id, :denormalized_object_method, :method_output

  FalseOutput = 0
  TrueOutput = 1

  def self.by_object_and_method_name(obj, method_name)
    attributes = {
      :denormalized_object_type => obj.class.name, 
      :denormalized_object_id => obj.id, 
      :denormalized_object_method => method_name
    }
    where(attributes).limit(1)
  end
end
