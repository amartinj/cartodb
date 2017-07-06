module Carto
  module Api
    module RecordsControllerAuth
      def load_user_table
        if @user_token
          @user_table = @user_token.table
        else
          @user_table = Carto::Helpers::TableLocator.new.get_by_id_or_name(params[:table_id], current_user)
        end
        raise RecordNotFound unless @user_table
      end

      def read_privileges?
        return true if @user_token
        head(401) unless current_user && @user_table.visualization.is_viewable_by_user?(current_user)
      end

      def write_privileges?
        if @user_token
          return @user_token.write_access || head(401)
        end
        head(401) unless current_user && @user_table.visualization.writable_by?(current_user)
      end
    end
  end
end
