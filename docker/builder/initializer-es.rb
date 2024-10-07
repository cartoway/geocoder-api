require 'csv'
require 'i18n'
I18n.available_locales = [:en]

CSV(STDOUT) { |out|
  out << ['lon', 'lat', 'id', 'street_type', 'street_name', 'number', 'ext', 'city' , 'postcode']
  CSV.parse(STDIN, headers: true) { |row|
    row = row.to_h.transform_values{ |r| r.nil? ? nil : r.strip }
    street_type = row['street_type'] != 'DESCONOCIDO' ? row['street_type'] : nil
    street_name = row['street_name']&.upcase # Already in upper case, just to be sure
    city = row['city']
    next if city.nil? || street_name.nil?

    # Remove duplicate street type
    if street_name && street_type && street_name.start_with?(street_type)
      street_name = street_name[..street_type.size].strip
    end

    if !city.nil? && !street_name.nil?
      city_upcase = I18n.transliterate(city).upcase
      street_name_cmp = I18n.transliterate(street_name)
      if (
        street_name_cmp != city_upcase &&
        (street_name_cmp.end_with?(city_upcase) || street_name_cmp.end_with?(city_upcase + ')')) &&
        !street_name_cmp.end_with?('-' + city_upcase) &&
        !Regexp.new("(D|DE|A) ?(AG.? )?#{city_upcase}$").match(street_name_cmp)
      )
        # puts row.inspect
        street_name = street_name[..-city_upcase.size - (street_name[-1] == ')' ? 1 : 0) - 1].strip
        # puts street_name
        street_name = street_name.gsub(/\.? ?\(?(AG.?)?$/, '').strip # AGREGADO
        # puts street_name
      end

      if street_name
        pre = /(:?([( ](:?DE LAS|DE LOS|LOS|DE LA|LAS|EL|DE|DEL|LA|O|OS|DOS|AS|DAS|DA|DO|DE|LES|DELS|DE LES|D'|DE L'|L'|DES|ELS)\)?)|(\(A\)))$/.match(street_name)
        if pre
          pre = pre[1]
          p = pre[1..]
          if p[-1] == ')'
            p = p[..-2]
          end
          street_name = p + ' ' + street_name[..-(pre.size + 1)].strip
        end
      end
    end

    # if row['street_name'] != street_name
    #   puts "#{row.values.inspect} -> #{street_name}"
    # end

    out << [row['X'], row['Y'], row['id'], street_type, street_name, row['number'], row['ext'], city, row['postcode']]
  }
}
