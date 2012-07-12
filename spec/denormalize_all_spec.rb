require 'spec_helper'

describe "denormalize_all" do
  describe "class methods" do
    describe "denormalize_all" do
      it "should call method_denormalization on all instances of the object" do
        @book = Book.new
        Book.stub(:all).and_return([@book])
        @book.should_receive(:method_denormalization)
        Book.denormalize_all
      end

      it "should call association_denormalization on all instances of the object" do
        @printing = Printing.new
        Printing.stub(:all).and_return([@printing])
        @printing.should_receive(:association_denormalization)
        Printing.denormalize_all
      end
    end
  end
end
