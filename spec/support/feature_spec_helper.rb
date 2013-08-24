module ReportHelpers
  def column_data_should_be_in_order(data_list)
    within 'table tbody tr:nth-of-type(1)' do
      page.should have_content data_list[0]
    end

    within 'table tbody tr:nth-of-type(2)' do
      page.should have_content data_list[1]
    end

    within 'table tbody tr:nth-of-type(3)' do
      page.should have_content data_list[2]
    end
  end
end
