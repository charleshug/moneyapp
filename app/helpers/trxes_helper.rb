module TrxesHelper

  def sort_link(column:, label:)
    column == params[:column] ? temp_direction = next_direction : temp_direction = 'asc'
    link_to(label, sort_trxes_path(column: column, direction: temp_direction))
  end

  def next_direction
    params[:direction] == 'asc' ? 'desc' : 'asc'
  end

end
