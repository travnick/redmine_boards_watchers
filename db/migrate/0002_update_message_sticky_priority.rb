class UpdateMessageStickyPriority < ActiveRecord::Migration
  def self.up
    Message.find(:all).each do |msg|
      if msg.sticky?
        msg.sticky_priority=1
        msg.save!
      end
    end
  end

  def self.down
  end
end
