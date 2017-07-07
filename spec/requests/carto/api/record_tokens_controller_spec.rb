# encoding: utf-8

require_relative '../../../spec_helper'

describe Carto::Api::RecordTokensController do
  MADEUP_TOKEN_ID = 'b0329749-a29a-4e80-9277-6bb2c64bbb22'
  describe 'Token handling' do

    before(:all) do
      @user = FactoryGirl.create(:valid_user)
      @user_table = Carto::UserTable.new(user: @user)   
    end

    before(:each) do
      bypass_named_maps
      delete_user_data @user
      @table = create_table(user_id: @user.id)
    end

    after(:all) do
      bypass_named_maps
      @user.destroy
    end

    let(:params) { { api_key: @user.api_key, table_id: @table.name, user_domain: @user.username } }

    it "Insert a token, get the list and find it" do
      token_id = nil
      
      post_json api_v1_tables_record_tokens_create_url(params) do |response|
        response.status.should be_success
        response.body[:permission].should == 'r'
        token_id = response.body[:id]
      end

      get_json api_v1_tables_record_tokens_index_url(params) do |response|
        response.status.should be_success
        response.body.first.should == token_id
      end

    end

    it "Insert a token, finds it, deletes it and tries to find again to fail" do
      token_id = nil

      post_json api_v1_tables_record_tokens_create_url(params) do |response|
        response.status.should be_success
        response.body[:permission].should == 'r'
        token_id = response.body[:id]
      end

      get_json api_v1_tables_record_tokens_show_url(params.merge(token_id: token_id)) do |response|
        response.status.should be_success
        response.body[:permission].should == 'r'
        response.body[:id].should == token_id
      end

      delete_json api_v1_tables_record_tokens_destroy_url(params.merge(token_id: token_id)) do |response|
        response.status.should == 204
      end

      get_json api_v1_tables_record_tokens_show_url(params.merge(token_id: token_id)) do |response|
        response.status.should == 404
      end

    end

    it "Insert a new token, update it and delete it" do
      payload = {
          permission: 'r'
      }
      post_json api_v1_tables_record_tokens_create_url(params.merge(payload)) do |response|
        response.status.should be_success
        response.body[:permission].should == payload[:permission]
        payload[:token_id] = response.body[:id]
      end

      payload[:permission] = 'rw'
      put_json api_v1_tables_record_tokens_update_url(params.merge(payload)) do |response|
        response.status.should be_success
        response.body[:permission.should] == payload[:permission]
      end

      delete_json api_v1_tables_record_tokens_destroy_url(params.merge(payload)) do |response|
        response.status.should == 204
      end

      get_json api_v1_tables_record_tokens_index_url(params) do |response|
        puts(response)
        response.status.should be_success
        response.body.should be_empty
      end
    end

    it 'Insert a token with an invalid permission' do
      post_json api_v1_tables_record_tokens_create_url(params.merge(permission: 'aaaa')) do |response|
        response.status.should == 400
      end
    end

    it 'Update a non-existing token' do
      put_json api_v1_tables_record_tokens_update_url(params.merge(token_id: MADEUP_TOKEN_ID)) do |response|
        response.status.should == 404
      end
    end
  end
end
