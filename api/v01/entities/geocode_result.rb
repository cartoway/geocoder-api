# Copyright © Mapotempo, 2015
#
# This file is part of Mapotempo.
#
# Mapotempo is free software. You can redistribute it and/or
# modify since you respect the terms of the GNU Affero General
# Public License as published by the Free Software Foundation,
# either version 3 of the License, or (at your option) any later version.
#
# Mapotempo is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
# or FITNESS FOR A PARTICULAR PURPOSE.  See the Licenses for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with Mapotempo. If not, see:
# <http://www.gnu.org/licenses/agpl.html>
#
require './api/v01/entities/geocode_result_feature'
require './api/v01/entities/geocode_result_geocoding'

module Api
  module V01
    class GeocodeResult < Grape::Entity
      def self.entity_name
        'GeocodeResult'
      end

      expose(:type, documentation: { type: String, desc: 'GeocodeJSON result is a FeatureCollection.' })
      expose(:geocoding, using: GeocodeResultGeocoding, documentation: { type: GeocodeResultGeocoding, desc: 'Namespace.' })
      expose(:features, using: GeocodeResultFeature, documentation: { type: GeocodeResultFeature, desc: 'As per GeoJSON spec.', is_array: true })
    end
  end
end
