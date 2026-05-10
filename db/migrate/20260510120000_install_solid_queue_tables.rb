# Solid Queue tables on the primary DB (single DATABASE_URL). Source: db/queue_schema.rb
class InstallSolidQueueTables < ActiveRecord::Migration[8.1]
  def up
    return if table_exists?(:solid_queue_jobs)

    load Rails.root.join("db/queue_schema.rb")
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
