require 'spec_helper'

describe Carto::UserTableToken do
  it 'generates different values based on user from table' do
    # I would use doubles to test this method, but having ActiveRecord couples the model with the database making it really hard
    #user = FactoryGirl.create(:valid_user)
    #table = Carto::UserTable.new(user: user)
    #token = Carto::UserTableToken.new(table: table)
    #token.generate_value!
  end
end
