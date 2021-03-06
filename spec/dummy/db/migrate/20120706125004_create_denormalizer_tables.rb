class  CreateDenormalizerTables < ActiveRecord::Migration
  def self.up
    create_table :denormalizer_method_outputs do |t|
      t.string :denormalized_object_type
      t.integer :denormalized_object_id
      t.string :denormalized_object_method
      t.integer :method_output

      t.timestamps
    end
    # used to get the result of a method from a single single object
    add_index :denormalizer_method_outputs, [:denormalized_object_type, :denormalized_object_id, :denormalized_object_method], :name => "denormalized_method_object_pair"
    # used to get all of the instances of a class with the same output for the given method
    add_index :denormalizer_method_outputs, [:denormalized_object_type, :denormalized_object_method, :method_output], :name => "denormalized_method_type_output_triplet"
  end

  def self.down
    drop_table :denormalizer_method_outputs
  end
end
