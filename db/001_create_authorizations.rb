Sequel.migration do 
  up do
    create_table :authorizations do
      primary_key :id

      String :provider
      String :uid
      Integer :user_id
    end
  end

  down do
    drop_table :authorizations
  end
end
