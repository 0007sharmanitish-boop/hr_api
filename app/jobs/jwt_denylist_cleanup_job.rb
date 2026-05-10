class JwtDenylistCleanupJob < ApplicationJob
  queue_as :default

  def perform
    JwtDenylist.purge_expired
  end
end
