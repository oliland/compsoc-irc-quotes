Sequel.migration do
  up do  
    create_table :quotes do
      primary_key :id

      Integer :user_id, :null => false
      String  :content, :null => false, :text => true
      Integer :votes
      
      DateTime :created_at
      Time :updated_at

      index [:id, :votes]
    end
  end
  
  down do
    drop_table :quotes
  end
end
