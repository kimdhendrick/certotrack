module ReportHelpers
  def column_data_should_be_in_order(*data_list)
    data_list.each_with_index do |data, index|
      row_number = index + 1
      within "table tbody tr:nth-of-type(#{row_number})" do
        page.should have_content data_list[index]
      end
    end
  end

  def assert_autocomplete(field_name, partial_value, full_value)
    fill_in field_name, with: partial_value
    sleep 1.5
    page.execute_script "$('.ui-menu-item a:contains(\"#{full_value}\")'). trigger(\"mouseenter\").click();"
    find_field(field_name).value.should eq full_value
  end
end
