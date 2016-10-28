require 'open-uri'

VARIABLES = [:VGRD, :UGRD]
LEVELS = [
  :lev_950_mb,
  :lev_925_mb,
  :lev_900_mb,
  :lev_850_mb,
  :lev_800_mb,
  :lev_750_mb,
  :lev_700_mb,
  :lev_650_mb,
  :lev_600_mb,
  :lev_550_mb,
  :lev_500_mb
]

var_params = VARIABLES.map { |x| "var_#{x}=on" }.join('&')
levels_params = LEVELS.map { |x| "#{x}=on" }.join('&')

# csc_lat = 41.892179
# csc_lon = -89.072115
# TODO: angle normalization

subregion = {
  subregion: '',
  leftlon: 270,
  rightlon: 272,
  toplat: 43,
  bottomlat: 40
}
subregion_params = subregion.map { |key, val| "#{key}=#{val}" }.join('&') 

baseurl = 'http://nomads.ncep.noaa.gov/cgi-bin/filter_gfs_0p25.pl?'

cycle_date = '20161023'
cycle = '18'
dir = "%2Fgfs.#{cycle_date}#{cycle}"
filename = "gfs.t#{cycle}z.pgrb2.0p25.anl"

url = "#{baseurl}file=#{filename}&dir=#{dir}&#{var_params}&#{levels_params}&#{subregion_params}"
p url
download = open(url)
IO.copy_stream(download, "./#{filename}")
