# http://prawnpdf.org/manual.pdf
module Export
  class PdfPresenter

    def initialize(collection, title, params = {})
      @exporter = ExporterFactory.new.instance(collection, :pdf, params)
      @title = title
    end

    def present
      pdf = Prawn::Document.new(page_layout: :landscape)
      pdf.text title, {size: 22, style: :bold}

      output = [exporter.headers]
      exporter.each do |model|
        output << exporter.column_names.map do |column_name|
          model.public_send(column_name)
        end
      end

      pdf.table output, header: true, row_colors: ['F0F0F0', 'FFFFCC'], cell_style: {size: 10}
      pdf.render
    end

    private

    attr_reader :exporter, :title
  end
end