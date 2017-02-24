class Api::V1::Comment < ActiveRecord::Base
  belongs_to :post
  belongs_to :user
end