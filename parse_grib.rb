require 'numru/grib'
include NumRu

ANALYTIC_KEYS = [:lat, :lon, :isobaricInhPa]

filename = 'gfs.t18z.pgrb2.0p25.anl'
grib = Grib.open(filename)

# Example of grib.var_names:
# ["u", "v"]
varnames = grib.var_names

# TODO: check V and U vars present

# Example of result of the following varnames.map
# [
#   [ {lat: 0, lon: 0, isobaricInhPa: 0, u: 11}. ... ]
#   [ {lat: 0, lon: 0, isobaricInhPa: 0, v: -7}, ... ]
# ]
var_vals = varnames.map do |vname|
  var = grib.var(vname) # => GribVar

  # Example of dim_names
  # [ "lon", "lat", "isobaricInhPa" ]
  dimensions = var.dim_names.map do |dn| 
    # Example of var.dim(dn).get
    # NArray.int(11):
    # [ 500, 550, 600, 650, 700, 750, 800, 850, 900, 925, 950 ]
    #
    # Example of result of following action
    # [
    #   {:lon=>270.0,  :index=>0},
    #   {:lon=>270.25, :index=>1},
    #   {:lon=>270.5,  :index=>2},
    #   {:lon=>270.75, :index=>3},
    #   {:lon=>271.0,  :index=>4},
    #   {:lon=>271.25, :index=>5}, 
    #   {:lon=>271.5,  :index=>6},
    #   {:lon=>271.75, :index=>7},
    #   {:lon=>272.0,  :index=>8}
    # ]
    var.dim(dn).get.to_a.map.with_index { |x, i| Hash[dn.to_sym, x, :index, i] } 
  end

  dimensions.shift.product(*dimensions).map do |x|
    dims = x.map { |x| x[:index] }
    data = x.reduce({}, :merge).select { |k,_| ANALYTIC_KEYS.include? k }
    data[vname.to_sym] = var.get(*dims).to_a.first
    data[:time] = DateTime.parse(var.att('time'))
    data
  end
end

grib.close

# As input it has:
# [
#   [ {lat: 0, lon: 0, isobaricInhPa: 0, u: 11}. ... ]
#   [ {lat: 0, lon: 0, isobaricInhPa: 0, v: -7}, ... ]
# ]
# Expected output:
# [ {lat: 0, lon: 0, isobaricInhPa: 0, u: 11, v: -7}. ... ]
merged = var_vals.reduce(:+).group_by{ |h| h.select { |k,_| ANALYTIC_KEYS.include? k } }.map { |k,v| v.reduce(:merge) }

# DIRECTION=57.29578*(arctangent(UGRD,VGRD))+180. 
# SPEED=SQRT(UGRD*UGRD+VGRD*VGRD) 
#
# merged.each { |x| p x }

