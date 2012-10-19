class CreateMessageStickyPriority < ActiveRecord::Migration
  def self.up
    add_column :messages, :sticky_priority, :integer, :default => 0
  end

  def self.down
    remove_column :messages, :sticky_priority
  end
end
