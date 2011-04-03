Sequel.migration do
  up do
    create_table :votes do
      primary_key :id

      Integer :user_id, :null => false
      Integer :quote_id, :null => false
      Integer :value, :null => false

      DateTime :created_at
      Time :updated_at

      index [:user_id, :quote_id], :unique => true
    end
  end

  down do
    drop_table :votes
  end
end
