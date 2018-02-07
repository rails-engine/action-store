# frozen_string_literal: true
module ActionStore
  module Model
    extend ActiveSupport::Concern

    included do
      # puts "Initialize ActionStore::Model"
      belongs_to :target, polymorphic: true
      belongs_to :user, polymorphic: true
    end
  end
end
