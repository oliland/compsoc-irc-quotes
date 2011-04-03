class User < Sequel::Model
  def save
    self.created_at ||= Time.now
    self.updated_at = Time.now
    super
  end
end
