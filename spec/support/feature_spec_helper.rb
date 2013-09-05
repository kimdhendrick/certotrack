module ReportHelpers
  def column_data_should_be_in_order(*data_list)
    data_list.each_with_index do |data, index|
      row_number = index + 1
      within "table tbody tr:nth-of-type(#{row_number})" do
        page.should have_content data_list[index]
      end
    end
  end
end
