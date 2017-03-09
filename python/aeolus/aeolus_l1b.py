import coda
from numpy import hstack, vstack

# change this to the full path of your Aeolus L1B DBL file
filename = "/path/to/AE_OPER_ALD_U_N_1B_20151002T001857059_005787000_046339_0001.DBL"

product = coda.open(filename)

### Observation profiles ###

# Observation profiles provide a single profile per BRC.
# Reading all values will therefore return 'an array of arrays' (we will get an array for each '-1' in the coda.fetch()).
# The first array is the list of BRCs, and the second array the list of points in the profile.
# This array of arrays can be turned into a single 2D numpy array of shape [num_brc, num_vertical] by using 'vstack'.

# Mie observation wind profiles

print("Mie observation wind profiles")

latitude = coda.fetch(product, 'geolocation', -1, 'observation_geolocation/observation_mie_geolocation', -1, 'latitude_of_height_bin')
latitude = vstack(latitude)

longitude = coda.fetch(product, 'geolocation', -1, 'observation_geolocation/observation_mie_geolocation', -1, 'longitude_of_height_bin')
longitude = vstack(longitude)

altitude = coda.fetch(product, 'geolocation', -1, 'observation_geolocation/observation_mie_geolocation', -1, 'altitude_of_height_bin')
altitude = vstack(altitude)

wind_velocity = coda.fetch(product, 'wind_velocity', -1, 'observation_wind_profile/mie_altitude_bin_wind_info', -1, 'wind_velocity')
wind_velocity = vstack(wind_velocity)

print(wind_velocity.shape)
print(wind_velocity)

# Rayleigh observation wind profiles

print("Rayleigh observation wind profiles")

latitude = coda.fetch(product, 'geolocation', -1, 'observation_geolocation/observation_rayleigh_geolocation', -1, 'latitude_of_height_bin')
latitude = vstack(latitude)

longitude = coda.fetch(product, 'geolocation', -1, 'observation_geolocation/observation_rayleigh_geolocation', -1, 'longitude_of_height_bin')
longitude = vstack(longitude)

altitude = coda.fetch(product, 'geolocation', -1, 'observation_geolocation/observation_rayleigh_geolocation', -1, 'altitude_of_height_bin')
altitude = vstack(altitude)

wind_velocity = coda.fetch(product, 'wind_velocity', -1, 'observation_wind_profile/rayleigh_altitude_bin_wind_info', -1, 'wind_velocity')
wind_velocity = vstack(wind_velocity)

print(wind_velocity.shape)
print(wind_velocity)

### Measurement profiles ###

# The measurement profiles provide the individual measured profiles per BRC
# This will thus provide 'an array of arrays of arrays'.
# The first array is the list of BRCs, the second array the list of measurements per BRC,
# and the final array the list of points in the profile.
# This array of arrays of arrays can be turned into a single 2D array of shape [num_brc * num_meas, num_vertical]
# by flattening the BRC and Measurement dimensions using 'hstack' and turning
# the array of profile arrays into a single 2D numpy array using 'vstack'.

# Note that the construction of the 'array of arrays of arrays' by coda.fetch() is done fully in Python
# which is not very fast. This is an inherent limitation of how CODA can deal with the XML-style structure used
# for the Aeolus L1b format (compared to a netcdf/hdf-style structure where all array dimensions are at the end). 

# Mie measurement wind profiles

print("Mie measurement wind profiles")

latitude = coda.fetch(product, 'geolocation', -1, 'measurement_geolocation', -1, 'mie_geolocation', -1, 'latitude_of_height_bin')
latitude = vstack(hstack(latitude))

longitude = coda.fetch(product, 'geolocation', -1, 'measurement_geolocation', -1, 'mie_geolocation', -1, 'longitude_of_height_bin')
longitude = vstack(hstack(longitude))

altitude = coda.fetch(product, 'geolocation', -1, 'measurement_geolocation', -1, 'mie_geolocation', -1, 'altitude_of_height_bin')
altitude = vstack(hstack(altitude))

wind_velocity = coda.fetch(product, 'wind_velocity', -1, 'measurement_wind_profile', -1, 'mie_altitude_bin_wind_info', -1, 'wind_velocity')
wind_velocity = vstack(hstack(wind_velocity))

print(wind_velocity.shape)
print(wind_velocity)

# Rayleigh measurement wind profiles

print("Rayleigh measurement wind profiles")

latitude = coda.fetch(product, 'geolocation', -1, 'measurement_geolocation', -1, 'rayleigh_geolocation', -1, 'latitude_of_height_bin')
latitude = vstack(hstack(latitude))

longitude = coda.fetch(product, 'geolocation', -1, 'measurement_geolocation', -1, 'rayleigh_geolocation', -1, 'longitude_of_height_bin')
longitude = vstack(hstack(longitude))

altitude = coda.fetch(product, 'geolocation', -1, 'measurement_geolocation', -1, 'rayleigh_geolocation', -1, 'altitude_of_height_bin')
altitude = vstack(hstack(altitude))

wind_velocity = coda.fetch(product, 'wind_velocity', -1, 'measurement_wind_profile', -1, 'rayleigh_altitude_bin_wind_info', -1, 'wind_velocity')
wind_velocity = vstack(hstack(wind_velocity))

print(wind_velocity.shape)
print(wind_velocity)

coda.close(product)
