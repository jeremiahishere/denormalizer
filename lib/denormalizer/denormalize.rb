module Denormalizer
  module Denormalize
    
    def self.included(base)
      base.extend ClassMethods
    end

    module ClassMethods
      def denormalize_all
        all.each do |o|
          # this could easily be rewritten in a less stupid way
          o.method_denormalization if self.respond_to? :denormalized_methods
          o.association_denormalization if self.respond_to? :denormalized_associations
        end
      end

      def denormalize(args)
        # setup list of denormalized methods 
        mattr_accessor :denormalized_methods unless respond_to? :denormalized_methods
        self.denormalized_methods = [] unless self.denormalized_methods.is_a?(Array)

        # add association
        has_many :denormalized_method_outputs, :class_name => 'Denormalizer::MethodOutput', :as => :denormalized_object, :dependent => :destroy

        # add args to denormalized method list
        args = [args] unless args.is_a?(Array)
        self.denormalized_methods |= args

        # create scopes
        # note that at some point, we probably need to identify these as denormalized scopes (JH 7-5-2012)
        # dn_method_name maybe
        args.each do |method_name|
          # setup true scope
          true_attributes = { 
            "denormalizer_method_outputs.denormalized_object_method" => method_name.to_s,
            "denormalizer_method_outputs.method_output" => Denormalizer::MethodOutput::TrueOutput
          }
          true_scope_name = "denormalized_#{method_name.to_s.gsub('?', '')}".pluralize.to_sym
          scope true_scope_name, lambda { joins(:denormalized_method_outputs).where(true_attributes)}

          # setup false scope
          false_attributes = {
            "denormalizer_method_outputs.denormalized_object_method" => method_name.to_s,
            "denormalizer_method_outputs.method_output" => Denormalizer::MethodOutput::FalseOutput
          }
          false_scope_name = "denormalized_not_#{method_name.to_s.gsub('?', '')}".pluralize.to_sym
          scope false_scope_name, lambda { joins(:denormalized_method_outputs).where(false_attributes)}

          instance_method_name = "denormalized_#{method_name.to_s}"
          define_method instance_method_name do
            saved_output = Denormalizer::MethodOutput.by_object_and_method_name(self, method_name).first
            return saved_output.method_output == Denormalizer::MethodOutput::TrueOutput
          end
        end

        after_save :method_denormalization

        include Denormalizer::Denormalize::InstanceMethods
      end

      def also_denormalize(args)
        mattr_accessor :denormalized_associations unless respond_to? :denormalized_associations
        self.denormalized_associations = [] unless self.denormalized_associations.is_a?(Array)

        args = [args] unless args.is_a?(Array)
        self.denormalized_associations |= args

        after_save :association_denormalization

        include Denormalizer::Denormalize::InstanceMethods
      end
    end

    module InstanceMethods

      def method_denormalization
        # don't even try if a new record
        if !new_record?
          # iterate over the saved methods 
          self.denormalized_methods.each do |method_name|
            # run the method and save the result
            method_output = self.send(method_name) ? Denormalizer::MethodOutput::TrueOutput : Denormalizer::MethodOutput::FalseOutput

            # find a match then create or update based on success
            # TODO: refactor this entire section to metho on Denormalizer::MethodOutput (JH 7-13-2012)
            saved_output = Denormalizer::MethodOutput.by_object_and_method_name(self, method_name).first
            if saved_output.nil?
              attributes = {
                :denormalized_object_type => self.class.name,
                :denormalized_object_id => self.id,
                :denormalized_object_method => method_name,
                :method_output => method_output
              }
              Denormalizer::MethodOutput.create(attributes)
            else
              saved_output.method_output = method_output
              saved_output.save
            end
          end
        end
      end

      def association_denormalization
        # TODO: make sure this doesn't loop infinitely (JH 7-13-2012)
        # if two models have a circular association or a model has a self association, this will not work
        self.denormalized_associations.each do |assoc_method|
          assoc = self.send(assoc_method)
          if assoc.is_a?(Array)
            assoc.each do |a|
              a.method_denormalization
            end
          else
            assoc.method_denormalization
          end
        end
      end
    end
  end
end
