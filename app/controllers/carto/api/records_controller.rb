# encoding: UTF-8

require_relative '../../../models/carto/permission'
require_relative 'records_controller_auth'

module Carto
  module Api
    class RecordsController < ::Api::ApplicationController
      include RecordsControllerAuth
      ssl_required :show, :create, :update, :destroy

      REJECT_PARAMS = %w{ format controller action row_id requestId column_id
                          api_key table_id oauth_token oauth_token_secret api_key user_domain user_token }.freeze

      before_filter :set_start_time
      before_filter :load_user_token, only: [:show, :create, :update, :destroy]
      before_filter :load_user_table, only: [:show, :create, :update, :destroy]
      before_filter :read_privileges?, only: [:show]
      before_filter :write_privileges?, only: [:create, :update, :destroy]
      after_filter  :clean_cookie, only: [:show, :create, :update, :destroy]

      # This endpoint is not used by the editor but by users. Do not remove
      def show
        render_jsonp(@user_table.service.record(params[:id]))
      rescue => e
        CartoDB::Logger.error(message: 'Error loading record', exception: e,
                              record_id: params[:id], user_table: @user_table)
        render_jsonp({ errors: ["Record #{params[:id]} not found"] }, 404)
      end

      def create
        primary_key = @user_table.service.insert_row!(filtered_row)
        render_jsonp(@user_table.service.record(primary_key))
      rescue => e
        render_jsonp({ errors: [e.message] }, 400)
      end

      def update
        if params[:cartodb_id].present?
          begin
            resp = @user_table.service.update_row!(params[:cartodb_id], filtered_row)

            if resp > 0
              render_jsonp(@user_table.service.record(params[:cartodb_id]))
            else
              render_jsonp({ errors: ["row identified with #{params[:cartodb_id]} not found"] }, 404)
            end
          rescue => e
            CartoDB::Logger.warning(message: 'Error updating record', exception: e)
            render_jsonp({ errors: [translate_error(e.message.split("\n").first)] }, 400)
          end
        else
          render_jsonp({ errors: ["cartodb_id can't be blank"] }, 404)
        end
      end

      def destroy
        user = get_current_user
        id = (params[:cartodb_id] =~ /\A\d+\z/ ? params[:cartodb_id] : params[:cartodb_id].to_s.split(','))
        schema_name = current_user.database_schema
        if user.id != @user_table.service.owner.id
          schema_name = @user_table.service.owner.database_schema
        end

        user.in_database
                    .select
                    .from(@user_table.service.name.to_sym.qualify(schema_name.to_sym))
                    .where(cartodb_id: id)
                    .delete

        head :no_content
      rescue
        render_jsonp({ errors: ["row identified with #{params[:cartodb_id]} not found"] }, 404)
      end

      def api_authorization_required
        authenticate!(:user_table_token_api, :api_key, :api_authentication, :scope => CartoDB.extract_subdomain(request))
      end

      def clean_cookie
        if @user_token
          puts("removing set-cookie from #{response.headers}")
          response.headers['Set-Cookie'] = nil
        end
      end

      protected

      def get_current_user
        if (@user_token)
          ::User[@user_token.table.user.id]
        else
          current_user
        end

      end

      def load_user_token
        return unless params[:user_token]
        @user_token = Carto::UserTableToken.where(value: params[:user_token]).first
      end

      def filtered_row
        params.reject { |k, _| REJECT_PARAMS.include?(k) }.symbolize_keys
      end
    end
  end
end
