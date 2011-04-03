class Vote < Sequel::Model

  def self.vote(user_id, quote_id, direction)
    user  = User[:id => user_id]
    quote = Quote[:id => quote_id]
    value = 1 if direction == 'up'
    value = -1 if direction == 'down'
    vote = Vote[:user_id => user.id, :quote_id => quote.id]
    if vote
      if vote.value == 1 and value == -1
        vote.value = value
        quote.votes = quote.votes - 2
      elsif vote.value == -1 and value == 1
        vote.value = value
        quote.votes = quote.votes + 2
      end
    else
      vote = Vote.create(:user_id => user.id, :quote_id => quote.id, :value => value)
      quote.votes += value
    end
    vote.save
    quote.save
    return quote
  end

  def save
    self.created_at ||= Time.now
    self.updated_at = Time.now
    super
  end

end
