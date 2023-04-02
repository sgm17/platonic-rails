class Api::V1::FlatsController < ApplicationController
    before_action :current_user, only: [:index, :create, :index_home, :bookmark, :add_remove_tenant, :set_flats]
    before_action :set_flat, only: [:show, :update, :destroy, :bookmark, :add_remove_tenant]
    before_action :set_flats, only: [:index, :index_home]

    # GET /api/v1/flats
    def index
        flat_models = @flats.map do |flat|
            bookmark = flat.bookmarks.exists?(user: @current_user)
            own_flat = flat.owner == @current_user
            image = flat.images.first
            
            transport = flat.transports.joins(user: :university)
                .where("universities.id = ?", @current_user.university_id)
                .first

            
            if transport.nil?
              transport = flat.transports.first
            end
            
            {
                id: flat.id,
                title: flat.title,
                rent_price_per_month_in_cents: flat.rent_price_per_month_in_cents,
                electricity_price_in_cents: flat.electricity_price_in_cents,
                book_mark: bookmark,
                transport: transport.as_json(
                    include: {
                        user: { 
                            except: [:meet_status, :sex_to_meet, :university_to_meet_id, :faculties_to_meet, :created_at, :updated_at],
                            include: {
                                university: { except: [:created_at, :updated_at] },
                                faculty: { except: [:created_at, :updated_at] },
                                study: { except: [:created_at, :updated_at] },
                            }
                        }
                    }
                ),
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
        is_add = params[:is_add]

        if tenant.nil?
            render json: { error: 'The user provided does not exist' }, status: :unprocessable_entity
            return
        end

        if tenant.email == @current_user.email
            render json: { error: 'You cannot add/remove yourself as a owner' }, status: :unprocessable_entity
            return
        end

        if is_add && @flat.tenants.map(&:email).include?(tenant.email)
            render json: { error: 'Tenant email already exists' }, status: :unprocessable_entity
            return
        end

        if @flat.tenants.include?(tenant)
            @flat.tenants.delete(tenant)

            @flat.transports.each do |transport|
                if transport.user == tenant
                  transport.destroy
                end
            end
        else
            @flat.tenants << tenant
        end

        if @flat.update(tenants: @flat.tenants)
            render json: @flat.tenants.as_json(
                except: [:meet_status, :sex_to_meet, :university_to_meet_id, :faculties_to_meet, :created_at, :updated_at],
                include: {
                    university: { except: [:created_at, :updated_at] },
                    faculty: { except: [:created_at, :updated_at] },
                    study: { except: [:created_at, :updated_at] },
                    faculties_to_meet: { only: [:id] }
                }), status: :ok
        else
            render json: @flat.errors, status: :unprocessable_entity
        end
    end

    # GET /api/v1/flats/index_home
    def index_home
        university = @current_user.university

        # Find the top floor flats of the university
        last_flat = @flats.first

        if last_flat.nil?
            render json: nil
            return
        end

        render json: {
            id: last_flat.id,
            title: last_flat.title,
            properties: last_flat.properties,
            rent_price_per_month_in_cents: last_flat.rent_price_per_month_in_cents,
            electricity_price_in_cents: last_flat.electricity_price_in_cents,
            bedroom: last_flat.bedroom,
            bathroom: last_flat.bathroom,
            image: last_flat.images.first
        }
    end

    # GET /api/v1/flats/flat_id
    def show
        book_mark = @flat.bookmarks.exists?(user: @current_user)

        render json: {
            id: @flat.id,
            owner: @flat.owner.as_json(
                except: [:meet_status, :sex_to_meet, :university_to_meet_id, :faculties_to_meet, :created_at, :updated_at],
                include: {
                    university: { except: [:created_at, :updated_at] },
                    faculty: { except: [:created_at, :updated_at] },
                    study: { except: [:created_at, :updated_at] },
                    faculties_to_meet: { only: [:id] }
                }
            ),
            tenants: @flat.tenants.as_json(
                except: [:meet_status, :sex_to_meet, :university_to_meet_id, :faculties_to_meet, :created_at, :updated_at],
                include: {
                    university: { except: [:created_at, :updated_at] },
                    faculty: { except: [:created_at, :updated_at] },
                    study: { except: [:created_at, :updated_at] },
                    faculties_to_meet: { only: [:id] }
                }
            ),
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
            transports: @flat.transports.as_json(
                include: {
                    user: { 
                        except: [:meet_status, :sex_to_meet, :university_to_meet_id, :faculties_to_meet, :created_at, :updated_at],
                        include: {
                            university: { except: [:created_at, :updated_at] },
                            faculty: { except: [:created_at, :updated_at] },
                            study: { except: [:created_at, :updated_at] },
                        }
                    }
                }
            ),
            images: @flat.images,
            book_mark: book_mark
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
        # Check if user has created more than 2 stories in the last 24 hours
        if @current_user.flats.where('created_at >= ?', 24.hours.ago).count >= 1
          render json: { error: 'You have reached the daily limit of flats creation' }, status: :too_many_requests
          return
        end

        @flat = Flat.new(flat_params)
        @flat.geometry = params[:geometry][0], params[:geometry][1]
        @flat.owner_id = @current_user.id

        properties = Property.new(properties_params)
        @flat.properties = properties

        transports_params = params[:transports]
        transport = transports_params.first
        @flat.transports.build(transport.permit(:name, :icon, :minutes).merge(user_id: @current_user.id))

        features_params = params[:features]
        features_params.each do |feature|
            @flat.features.build(feature.permit(:name, :icon))
        end

        if @flat.save
            render json:  {
                id: @flat.id,
                title: @flat.title,
                rent_price_per_month_in_cents: @flat.rent_price_per_month_in_cents,
                electricity_price_in_cents: @flat.electricity_price_in_cents,
                book_mark: false,
                transport: transport.as_json(
                    include: {
                        user: { 
                            except: [:meet_status, :sex_to_meet, :university_to_meet_id, :faculties_to_meet, :created_at, :updated_at],
                            include: {
                                university: { except: [:created_at, :updated_at] },
                                faculty: { except: [:created_at, :updated_at] },
                                study: { except: [:created_at, :updated_at] },
                            }
                        }
                    }
                ),
                properties: properties,
                image: @flat.images.first,
                own_flat: true,
                bedroom: @flat.bedroom,
                bathroom: @flat.bathroom,
                built: @flat.built
            }, status: :created
        else
            render json: @flat.errors, status: :unprocessable_entity
        end
    end

    # DELETE /api/v1/flats/:flat_id
    def destroy
        if @flat.destroy
            render json: { destroyed: true }
        else
            render json: @flat.errors, status: :unprocessable_entity
        end
    end

    # PATCH/PUT /api/v1/flats/flat_id
    def update
        if @flat.update(flat_params)
            # Update properties
            @flat.properties.update(properties_params)

            # Update features list
            features_params = params[:features]

            # Get existing feature IDs
            existing_feature_ids = @flat.features.pluck(:id)

            # Iterate through the feature parameters
            features_params.each do |feature|
              if feature[:id].present?
                # Update existing feature
                @flat.features.find(feature[:id]).update(feature.permit(:name, :icon))
                # Remove the ID from the list of existing feature IDs
                existing_feature_ids.delete(feature[:id].to_i)
              else
                # Create new feature
                @flat.features.build(feature.permit(:name, :icon))
              end
            end

            # Delete features that were not included in the parameter list
            @flat.features.where(id: existing_feature_ids).destroy_all

            # Update transports list
            transports_params = params[:transports]
                    
            # Update existing transports
            transports_params.each_with_index do |transport, index|
                # Find the transport by ID
                current_transport = @flat.transports.find_by(id: transport[:id])

                if current_transport.nil?
                    # Create a new transport for a tenant that doesn't have one
                    tenant = @flat.tenants[index - 1]
                    @flat.transports.create(transport.permit(:name, :icon, :minutes).merge(user_id: tenant.id))
                  else
                    # If the transport exists, update it
                    current_transport.update(transport.permit(:name, :icon, :minutes))
                  end
            end

            transport = @flat.transports.first

            render json:  {
                id: @flat.id,
                title: @flat.title,
                rent_price_per_month_in_cents: @flat.rent_price_per_month_in_cents,
                electricity_price_in_cents: @flat.electricity_price_in_cents,
                book_mark: false,
                transport: transport.as_json(
                    include: {
                        user: { 
                            except: [:meet_status, :sex_to_meet, :university_to_meet_id, :faculties_to_meet, :created_at, :updated_at],
                            include: {
                                university: { except: [:created_at, :updated_at] },
                                faculty: { except: [:created_at, :updated_at] },
                                study: { except: [:created_at, :updated_at] },
                            }
                        }
                    }
                ),
                properties: @flat.properties,
                image: @flat.images.first,
                own_flat: true,
                bedroom: @flat.bedroom,
                bathroom: @flat.bathroom,
                built: @flat.built
            }, status: :ok
        else
          render json: @flat.errors, status: :unprocessable_entity
        end
    end

    private

    def set_flat
        @flat = Flat.find(params[:id])
    end

    def set_flats
        @flats = Flat.joins(owner: :university)
                    .joins("LEFT JOIN flats_tenants ON flats_tenants.flat_id = flats.id")
                    .joins("LEFT JOIN users ON users.id = flats_tenants.user_id")
                    .where('users.university_id = ? OR universities.id = ?', @current_user.university_id, @current_user.university_id)
                    .order(created_at: :desc)
    end

    def flat_params
        params.require(:flat).permit(
            :title, :description, :currency, :rent_price_per_month_in_cents, :advance_price_in_cents,
            :electricity_price_in_cents, :available_from, :max_months_stay, :min_months_stay, :tenants_number, :bedroom, :bathroom,
            :built, :floor, :properties, :images => [], :geometry => [], 
            properties: [:country, :city, :countrycode, :postcode, :county, :housename, :name, :state],
            features: [:id, :name, :icon],
            transports: [:id, :name, :icon, :minutes, user: [:id]]
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
