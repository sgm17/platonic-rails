class Api::V1::FlatsController < ApplicationController
    before_action :current_user, only: [:index, :create, :index_home, :bookmark]
    before_action :set_flat, only: [:show, :update, :destroy, :bookmark, :add_remove_tenant]

    # GET /api/v1/flats
    def index
        flats = Flat.joins(owner: :university)
                    .where('users.university_id = ? OR universities.id = ?', @current_user.university_id, @current_user.university_id)

            flat_models = flats.map do |flat|
            bookmark = flat.bookmarks.exists?(user: @current_user)
            own_flat = flat.owner == @current_user
            image = flat.list_of_images.first

            transports = flat.transports.find_by(university_id: @current_user.university_id)

            {
                id: flat.id,
                title: flat.title,
                rent_price_per_month_in_cents: flat.rent_price_per_month_in_cents,
                electricity_price_in_cents: flat.electricity_price_in_cents,
                book_mark: bookmark,
                transports: transports,
                properties: flat.properties,
                image: image,
                own_flat: own_flat,
                bedroom: flat.bedroom,
                bathroom: flat.bathroom,
                built: flat.built
            }
            end
        render json: flat_models
    end

    # POST /api/v1/flats/flat_id/add_remove_tenant
    def add_remove_tenant
        tenant = User.find_by(email: params[:tenant_email])

        if tenant.email == @current_user.email
            render json: { error: 'You cannot add/remove yourself as a owner' }, status: :unprocessable_entity
            return
        end

        if @flat.tenants.include?(tenant)
            @flat.tenants.delete(tenant)
        else
            @flat.tenants << tenant
        end

        if @flat.update(tenants: @flat.tenants)
            render json: @flat.tenants, status: :ok
        else
            render json: { error: 'Failed to update flat' }, status: :unprocessable_entity
        end
    end

    # GET /api/v1/flats/index_home
    def index_home
        university = @current_user.university

        # Find the top floor flats of the university
        last_flat = Flat.joins(owner: :university)
                    .where('users.university_id = ? OR universities.id = ?', @current_user.university_id, @current_user.university_id).last

        render json: {
            id: last_flat.id,
            title: last_flat.title,
            properties: last_flat.properties,
            rent_price_per_month_in_cents: last_flat.rent_price_per_month_in_cents,
            electricity_price_in_cents: last_flat.electricity_price_in_cents,
            bedroom: last_flat.bedroom,
            bathroom: last_flat.bathroom,
            image: last_flat.list_of_images.first
        }
    end

    # GET /api/v1/flats/flat_id
    def show
        book_mark = @flat.bookmarks.exists?(user: @current_user)
        own_flat = @flat.owner == @current_user

        render json: {
            id: @flat.id,
            owner: @flat.owner,
            tenants: @flat.tenants,
            title: @flat.title,
            description: @flat.description,
            properties: @flat.properties,
            geometry: [@flat.geometry["x"], @flat.geometry["y"]],
            currency: @flat.currency,
            rent_price_per_month_in_cents: @flat.rent_price_per_month_in_cents,
            advance_price_in_cents: @flat.advance_price_in_cents,
            electricity_price_in_cents: @flat.electricity_price_in_cents,
            available_from: @flat.available_from,
            max_months_stay: @flat.max_months_stay,
            min_months_stay: @flat.min_months_stay,
            tenants_number: @flat.tenants_number,
            bedroom: @flat.bedroom,
            bathroom: @flat.bathroom,
            built: @flat.built,
            floor: @flat.floor,
            features: @flat.features,
            transports: @flat.transports,
            images: @flat.list_of_images,
            book_mark: book_mark,
            own_flat: own_flat
        }
    end
      

    # POST /api/v1/flats/flat_id/bookmark
    def bookmark
        if @flat.bookmarked_by?(@current_user)
            @flat.bookmarks.find_by(user: @current_user).destroy
            render json: { book_mark: false }
        else
            @flat.bookmarks.create(user: @current_user)
            render json: { book_mark: true }
        end
    end

    # POST /api/v1/flats
    def create
        @flat = Flat.new(flat_params)
        @flat.geometry = params[:geometry][0], params[:geometry][1]
        @flat.owner_id = @current_user.id

        properties = Property.new(properties_params)
        @flat.properties = properties

        transports_params = params[:transports]
        transports_params.each do |t|
            university_id = t[:university][:id]
            transport = @flat.transports.build(t.permit(:name, :icon, :minutes).merge(university_id: university_id))
        end

        features_params = params[:features]
        features_params.each do |f|
            feature = @flat.features.build(f.permit(:name, :icon))
        end

        if @flat.save
            render json:  {
                id: @flat.id,
                title: @flat.title,
                rent_price_per_month_in_cents: @flat.rent_price_per_month_in_cents,
                electricity_price_in_cents: @flat.electricity_price_in_cents,
                book_mark: false,
                transport: @flat.transports.includes(:university).first.as_json(include: :university),
                properties: properties,
                #image: @flat.list_of_images.first,
                image: "https://www.habitatapartments.com/resources/apartments/846x564/puerto-banus-apartment-marbella_a.jpg",
                own_flat: true,
                bedroom: @flat.bedroom,
                bathroom: @flat.bathroom,
                built: @flat.built
            }, status: :created
        else
            render json: @flat.errors, status: :unprocessable_entity
        end
    end

    # DELETE /api/v1/flats/flat_id
    def destroy
        @flat.destroy
    end

    # PATCH/PUT /api/v1/flats/flat_id
    def update
        if @flat.update(flat_params)
            # Update properties
            @flat.properties.update(properties_params)

            # Update features list
            features_params = params[:features]
            features_params.each do |f|
                feature = @flat.features.find(f[:id]).update(f) 
            end

            # Update transports list
            transports_params = params[:transports]
            transports_params.each do |t|
                transport = @flat.transports.find(t[:id]).update(t)
            end

            render json: @flat, include: [:transports, :properties, :features], status: :ok
        else
          render json: { errors: @flat.errors.full_messages }, status: :unprocessable_entity
        end
    end

    private

    def set_flat
        @flat = Flat.find(params[:id])
    end

    def flat_params
        params.require(:flat).permit(
            :title, :description, :currency, :rent_price_per_month_in_cents, :advance_price_in_cents,
            :electricity_price_in_cents, :available_from, :max_months_stay, :min_months_stay, :tenants_number, :bedroom, :bathroom,
            :built, :floor, :properties, :list_of_images => [], :geometry => [], 
            properties: [:country, :city, :countrycode, :postcode, :county, :housename, :name, :state],
            features: [:id, :name, :icon],
            transports: [:id, :name, :icon, :minutes, university: [:id, :name, :simple_name]]
        )
    end
    
    def properties_params
        params.require(:properties).permit(
            :country,
            :city,
            :countrycode,
            :postcode,
            :county,
            :housenumber,
            :name,
            :state
        )
    end
end
