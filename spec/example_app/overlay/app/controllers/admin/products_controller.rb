module Admin
  class ProductsController < ApplicationController
    private

    def find_resource(id)
      scoped_resource.find_by!(slug: id)
    end
  end
end
