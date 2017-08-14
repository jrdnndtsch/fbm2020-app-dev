class GenerateReportPdfJob < ApplicationJob
  queue_as :default

  def perform(*args)
    # Do something later
    items = args[0][:items]

    @report = @report = Report.find args[0][:report_id]

    # create an instance of ActionView, so we can use the render method outside of a controller
    av = ActionView::Base.new()
    av.view_paths = ActionController::Base.view_paths

    # need these in case your view constructs any links or references any helper methods.
    av.class_eval do
      include Rails.application.routes.url_helpers
      include ApplicationHelper
    end

    pdf_html = av.render template: 'api/v1/reports/generate_report', layout: 'layouts/pdf', locals: {report: @report, items: items }

    # use wicked_pdf gem to create PDF from the doc HTML
    doc_pdf = WickedPdf.new.pdf_from_string(
      pdf_html,
      page_size: 'Letter',
      javascript_delay: 100
    )

    # save PDF to disk
    pdf_path = Rails.root.join('tmp/reports', "#{@report.id}_#{Date.today.iso8601}.pdf")
    File.open(pdf_path, 'wb') do |file|
      file << doc_pdf
    end

    @report.pdf = File.open pdf_path
    @report.save!

    # The report has now been saved elsewhere using Paperclip; we don't need to store it locally
    File.delete(pdf_path) if File.exist?(pdf_path)

    # email the report
    ReportPdfMailer.send_mail(@report.id).deliver
  end
end
