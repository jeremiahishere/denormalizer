class Book < ActiveRecord::Migration
  def up
    create_table :books do |t|
      t.string :name

      t.timestamps
    end

    create_table :printings do |t|
      t.integer :book_id
      t.string :version

      t.timestamps
    end
  end

  def down
    drop_table :books
    drop_table :printings
  end
end
