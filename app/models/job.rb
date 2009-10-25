class Job < ActiveRecord::Base

belongs_to :runnable, :polymorphic => true

end
