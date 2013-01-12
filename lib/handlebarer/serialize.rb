module Handlebarer

  module Serialize

    module ClassMethods

      # Enable serialization on ActiveModel classes
      # @param [Array<Symbol>] args model attribute names to serialize
      # @param [Hash] args options serializing mode
      # @option args [Boolean] :merge should serialized attributes be merged with `self.attributes`
      # @example
      #     class User < ActiveRecord::Base
      #       include Handlebarer::Serialize
      #       hbs_serializable :name, :email, :merge => false
      #     end
      def hbs_serializable(*args)
        serialize = {
          :attrs => [],
          :merge => true
        }
        args.each do |arg|
          if arg.is_a? Symbol
            serialize[:attrs] << arg
          elsif arg.is_a? Hash
            serialize[:merge] = arg[:merge] if arg.include?(:merge)
          end
        end
        class_variable_set(:@@serialize, serialize)
      end

    end

    #nodoc
    def self.included(base)
      base.extend ClassMethods
    end

    # Serialize instance attributes to a Hash based on serializable attributes defined on Model class.
    # @return [Hash] hash of model instance attributes
    def to_hbs
      h = {:model => self.class.name.downcase}
      self.hbs_attributes.each do |attr|
        h[attr] = self.send(attr)

        ans = h[attr].class.ancestors
        if h[attr].class.respond_to?(:hbs_serializable) || ans.include?(Enumerable) || ans.include?(ActiveModel::Validations)
          h[attr] = h[attr].to_hbs
        else
        end
      end
      h
    end

    # List of Model attributes that should be serialized when called `to_hbs` on Model instance
    # @return [Array] list of serializable attributes
    def hbs_attributes
      s = self.class.class_variable_get(:@@serialize)
      if s[:merge]
        attrs = s[:attrs] + self.attributes.keys
      else
        attrs = s[:attrs]
      end
      attrs.collect{|attr| attr.to_sym}.uniq
    end
  end

end

class Object
  # Serialize Object to Jade format. Invoke `self.to_hbs` if instance responds to `to_hbs`
  def to_hbs
    if self.respond_to? :to_a
      self.to_a.to_hbs
    else
      nil
    end
  end
end

#nodoc
[FalseClass, TrueClass, Numeric, String].each do |cls|
  cls.class_eval do
    def to_hbs
      self
    end
  end
end

class Array

  # Serialize Array to Handlebarer format. Invoke `to_hbs` on array members
  def to_hbs
    map {|a| a.respond_to?(:to_hbs) ? a.to_hbs : a }
  end
end

class Hash

  # Serialize Hash to Handlebarer format. Invoke `to_hbs` on members
  def to_hbs
    res = {}
    each_pair do |key, value|
      res[key] = (value.respond_to?(:to_hbs) ? value.to_hbs : value)
    end
    res
  end
end