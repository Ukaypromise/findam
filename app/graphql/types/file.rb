# frozen_string_literal: true

module Types
  class File < Types::BaseScalar
    description "Input file type, returns file url for output"

    def self.coerce_input(input_value, context)
      file = input_value
      ActionDispatch::Http::UploadedFile.new(
        filename: file.original_filename,
        type: file.content_type,
        head: file.headers,
        tempfile: file.tempfile,
      )
    end

    def self.coerce_result(file, _ctx)
      return { url: nil, file_name: nil } unless file&.blob

      url = Rails.application.routes.url_helpers.url_for(file)
      file_name = file.blob.filename.to_s rescue nil

      { url: url, file_name: file_name }
    rescue => e
      Rails.logger.error "File URL error: #{e.message}"
      { url: nil, file_name: nil }
    end
  end
end
