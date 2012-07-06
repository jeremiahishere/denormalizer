class Denormalizer::MethodOutput < ActiveRecord::Base
  set_table_name "denormalizer_method_outputs"

  belongs_to :denormalized_object, :polymorphic => true
  validates_presence_of :denormalized_object_type, :denormalized_object_id, :denormalized_object_method, :method_output

  FalseOutput = 0
  TrueOutput = 1
end
