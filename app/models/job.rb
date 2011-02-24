class Job < ActiveRecord::Base

  belongs_to :runnable, :polymorphic => true
  validates_presence_of :runnable_id
end
