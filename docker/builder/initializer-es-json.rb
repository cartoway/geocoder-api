require 'csv'
require 'json'

CSV.parse(STDIN, headers: true).group_by{ |row| [row['city'], row['street_type'], row['street_name']] }.each{ |id, dirs|
  dirs = dirs.collect{ |dir|
    dir['number'] = dir['number'].to_i
    dir['lat'] = dir['lat'].to_f
    dir['lon'] = dir['lon'].to_f
    dir
  }.sort_by{ |dir| dir['number'] }
  housenumbers = dirs.to_h{ |dir|
    [
      [dir['number'], dir['ext']].compact.join(' '),
      {
        lat: dir['lat'].to_f,
        lon: dir['lon'].to_f,
      }
    ]
  }

  name = [dirs[0]['street_type'], dirs[0]['street_name']].compact.join(' ')
  if name != ''
    puts({
      id: dirs[0]['id'],
      citycode: dirs[0]['id'][0..4],
      type: 'street',
      city: dirs[0]['city'],
      name: name,
      postcode: dirs[0]['postcode'],
      lat: dirs[dirs.size / 2]['lat'],
      lon: dirs[dirs.size / 2]['lon'],
      importance: 0.2,
      housenumbers: housenumbers
    }.to_json)
  end
}
