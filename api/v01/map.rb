# Copyright © Mapotempo, 2018
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

module Api
  module V01
    class Map < APIBase
      require 'grape-erb'

      content_type :js, 'text/javascript'
      formatter :js, Grape::Formatter::Erb
      default_format :js
      resource :map do
        desc 'Provide javascript sdk.', {
          nickname: 'map',
          failures: [
            {code: 400, model: Status}
          ]
        }
        get '/', erb: 'map' do
          count_incr :map, transactions: 1
        end
      end
    end
  end
end
