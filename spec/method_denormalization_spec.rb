require 'spec_helper'
require 'ruby-debug'

describe "method denormalization" do
  before(:each) { @book = Book.new }
  subject { @book }

  describe "class methods" do
    describe "denormalize" do
      it "should add to the denormalized_method_outputs array" do
        @book.denormalized_methods.should include :short_name?      
        @book.denormalized_methods.should include :printed?      
      end

      it "should create a scope called denormalized_method_names for the method method_name?" do
        Book.should respond_to :denormalized_short_names
      end

      it "should create a scope called denormalized_not_method_names for the method method_name?" do
        Book.should respond_to :denormalized_not_short_names
      end

      it "should add method_denormalization to the after_save" do
        @book.should_receive(:method_denormalization)
        @book.save(:validate => false)
      end
    end
  end

  # these tests are dependent on the Book model denormalizing the short_name? and printed?
  describe "scopes" do
    describe "denormalized_short_names" do
      it "should match this sql" do
        sql = Book.denormalized_short_names.to_sql 
        sql.should match "INNER JOIN denormalizer_method_outputs AS dnmos_books_0 on dnmos_books_0.denormalized_object_type='Book' AND dnmos_books_0.denormalized_object_id=books.id"
        sql.should match "WHERE \"dnmos_books_0\".\"denormalized_object_method\" = 'short_name.' AND \"dnmos_books_0\".\"method_output\" = 1"
      end
    end

    describe "denormalized_not_short_names" do
      it "should match this sql" do
        sql = Book.denormalized_not_short_names.to_sql 
        sql.should match "INNER JOIN denormalizer_method_outputs AS dnmos_books_0 on dnmos_books_0.denormalized_object_type='Book' AND dnmos_books_0.denormalized_object_id=books.id"
        sql.should match "WHERE \"dnmos_books_0\".\"denormalized_object_method\" = 'short_name.' AND \"dnmos_books_0\".\"method_output\" = 0"
      end
    end
  end

  describe "methods" do
    describe "denormalized_short_name?" do
      it "should include the denormalized method" do
        @book.should respond_to :denormalized_short_name?
      end

      it "should match the actual output if synced" do
        @book.name = "abc"
        @book.save
        @book.short_name?.should equal @book.denormalized_short_name?
      end
    end

    describe "method_denormalization" do
      before(:each) do
        @book.stub(:new_record?).and_return(false)
        @book.stub(:id).and_return(1000)
        @book.name = "The Tale of Two Cities"
      end

      it "should do nothing for new records" do
        @book.stub(:new_record?).and_return(true)
        @book.should_not_receive(:denormalized_methods)
        @book.method_denormalization
      end

      it "should call each denormalized method" do
        @book.should_receive(:short_name?)
        @book.should_receive(:printed?)
        @book.method_denormalization
      end

      it "should save the output of each denormalized method to the database" do
        @book.method_denormalization
        Denormalizer::MethodOutput.where(:denormalized_object_type => "Book", :denormalized_object_id => 1000, :denormalized_object_method => "short_name?").should_not be_empty
      end
    end
  end
end
