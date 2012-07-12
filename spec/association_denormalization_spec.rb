require 'spec_helper'

describe "association denormalization" do
  before(:each) { @printing = Printing.new }
  subject { @printing }

  describe "class methods" do
    describe "also_denormalize" do
      it "should add to the denormalized_associations array" do
        @printing.denormalized_associations.should include :book      
      end

      it "should add association_denormalization to the after_save" do
        @printing.should_receive(:association_denormalization)
        @printing.save(:validate => false)
      end
    end
  end

  describe "instance methods" do
    describe "association_denormalization" do
      before(:each) do
        @book = Book.new
      end

      it "should call method_denormalization for the association" do
        @printing.book = @book
        @book.should_receive(:method_denormalization)
        @printing.association_denormalization
      end

      it "should call method_denormalization for each member of the association if it is an array" do
        @printing.stub(:book).and_return([@book])
        @book.should_receive(:method_denormalization)
        @printing.association_denormalization
      end
    end
  end
end
