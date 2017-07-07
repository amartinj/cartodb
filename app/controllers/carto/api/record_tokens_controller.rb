require_relative 'records_controller_auth'

module Carto
  module Api
    class RecordTokensController < ::Api::ApplicationController
      include RecordsControllerAuth

      before_filter :set_start_time
      before_filter :load_user_table, only: [:index, :show, :create, :update, :destroy]
      before_filter :read_privileges?, only: [:index, :show]
      before_filter :write_privileges?, only: [:create, :update, :destroy]

      def index
        render_jsonp(@user_table.tokens.collect{ |token| token.id})
      end

      def show
        token = @user_table.tokens.find(params[:cartodb_id])
        render_jsonp(token_as_array token)
      end

      def create
        token = Carto::UserTableToken.new(write_access: token_write_access?)
        @user_table.tokens << token
        token.generate_value!
        render_jsonp(token_as_array token)
      end

      def update
        token = Carto::UserTableToken.find(params[:cartodb_id])
        head (404) unless token
        token.write_access = token_write_access?
        render_jsonp(token_as_array token)
      end

      def destroy
        Carto::UserTableToken.destroy(params[:cartodb_id])
        head :no_content
      end

      protected
      
      def token_write_access?
        return false unless params[:permission]
        permission = params[:permission].downcase
        raise "Invalid permission: #{permission}" unless permission.include? 'r'
        permission.include? 'w'
      end

      def token_as_array(token)
        {
            id: token.id,
            value: token.value,
            permission: token.write_access ? 'rw' : 'r'
        }
      end
    end
  end
end
