# frozen_string_literal: true
class NotionDatabaseController < ApplicationController
  def index    
    tables = current_user.notion_tables
    database_id = params[:database_id]
    
    selected_table = tables.find { |table| table.database_id == database_id }

    if selected_table      
      notion_access_token = selected_table.user.notion_access_token
      @data = NotionService.get_data(database_id, notion_access_token)
      
      if @data.present?       
        @columns = @data.flat_map(&:keys).uniq
      else
        @columns = []
        flash[:alert] = "No data found for the selected database."
      end
    else
      @data = []
      @columns = []
      flash[:alert] = "No matching table found for the database ID provided."
    end

    @current_user = current_user
  end

  private

  def database_id_params
    params.permit(:database_id)
  end
end
