require 'aws-sdk-s3'

class Api::V1::ImagesController < ApplicationController
    # GET /api/v1/images?:name&:format
    def index
        begin
            # Extract the file name and extension from the URL
            name = params[:name]
            format = params[:format]
        
            s3 = s3_resource
            bucket = s3.bucket(ENV['AWS_BUCKET_NAME'])
            object = bucket.object("#{name}.#{format}")
            
            image_data = object.get.body.read
  
            send_data image_data, type: "image/#{format}", disposition: 'inline'
        rescue => e
            render json: { error: e.message }, status: :unprocessable_entity
        end
    end

    # POST /api/v1/images
    def create
        begin
            s3 = s3_resource
            bucket = s3.bucket(ENV['AWS_BUCKET_NAME'])
            object = bucket.object(params[:image].original_filename)
            object.upload_file(params[:image].tempfile, acl: 'private')
            name = object.public_url.split('.')[0]
            format = object.public_url.split('.')[1]
            
            render json: { name: name, format: format }, status: :created
        rescue => e
            render json: { error: e.message }, status: :unprocessable_entity
        end
    end

    # POST /api/v1/create_multiple
    def create_multiple
        name_format = []
        params[:images].each do |image|
            begin
                s3 = s3_resource
                bucket = s3.bucket(ENV['AWS_BUCKET_NAME'])
                object = bucket.object(image.original_filename)
                object.upload_file(image.tempfile, acl: 'private')
                name = object.public_url.split('.')[0]
                format = object.public_url.split('.')[0]

                name_format << {name: name, format: format}
            rescue => e
                render json: { error: e.message }, status: :unprocessable_entity
            end
        end
        render json: { images: name_format }, status: :created
    end

    private

    def s3_resource
        Aws::S3::Resource.new(
          access_key_id: ENV['AWS_ACCESS_KEY_ID'],
          secret_access_key: ENV['AWS_SECRET_ACCESS_KEY'],
          region: ENV['AWS_REGION']
        )
    end
end
