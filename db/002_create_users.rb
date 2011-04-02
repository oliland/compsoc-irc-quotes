Sequel.migration do
  up do
    create_table! :users do
      primary_key :id
      
      String      :first_name,        :null => false
      String      :last_name,         :null => false
      String      :username
      Time        :last_login
      DateTime    :created_at,        :null => false
      Time        :updated_at
    end
  end
  
  down do
    drop_table :users
  end
end
