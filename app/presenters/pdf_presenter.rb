# http://prawnpdf.org/manual.pdf
class PdfPresenter
  include PresenterHelper

  attr_reader :collection, :title

  def initialize(collection, title, params = {})
    @collection = EquipmentListPresenter.new(collection).sort(params)
    @title = title
  end

  def present
    pdf = Prawn::Document.new(page_layout: :landscape)
    pdf.text title, {size: 22, style: :bold}

    output = [EquipmentPresenterHelper::HEADERS]
    collection.each do |equipment|
      output << equipment_column_names.map do |column_name|
        equipment.public_send(column_name)
      end
    end

    pdf.table output, header: true, row_colors: ['F0F0F0', 'FFFFCC'], cell_style: {size: 10}
    pdf.render
  end

  def equipment_column_names
    EquipmentPresenterHelper::COLUMNS.map(&:to_s)
  end
end