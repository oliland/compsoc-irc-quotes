class Quote < Sequel::Model
  def save
    self.created_at ||= Time.now
    self.updated_at = Time.now
    super
  end

  def created_date
    self.created_at.strftime "%B %d, %Y"
  end
end
