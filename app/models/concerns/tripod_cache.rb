module TripodCache

  extend ActiveSupport::Concern

  included do
    after_save :clear_tripod_cache
    after_destroy :clear_tripod_cache
  end

  def clear_tripod_cache
    Tripod.cache_store.clear!
  end

end