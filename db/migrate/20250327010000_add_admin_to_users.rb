class AddAdminToUsers < ActiveRecord::Migration[7.1]
  def change
    # The admin column already exists in the users table
    # This is a dummy migration that does nothing
    # It exists only to satisfy Rails' migration system
    reversible do |dir|
      dir.up do
        # Do nothing in the up direction
        say "Admin column already exists in users table - skipping migration"
      end

      dir.down do
        # Do nothing in the down direction
        say "This is a dummy migration - nothing to roll back"
      end
    end
  end
end
