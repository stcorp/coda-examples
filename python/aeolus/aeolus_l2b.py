import os

# Change this to the location of your AEOLUS codadef file
os.putenv('CODA_DEFINITION', '/usr/local/share/coda/definitions')
# You can also remove this line and set the CODA_DEFINITION environment variable globally on your system

import coda
from numpy import vstack, zeros

# change this to the full path of your Aeolus L2B DBL file
filename = "/path/to/AE_OPER_ALD_U_N_2B_20071107T193753_20071107T220253_0001.DBL"

product = coda.open(filename)

# The L2B product stores all valid profile points (which are called 'results') as one big consecutive array
# in the datasets mie_hloswind and rayleigh_hloswind.
# The associated geolocation for those point results are stored in mie_geolocation and rayleigh_geolocation.
#
# The specification of which points belong together in which profile is kept in the mie_profile and rayleigh_profile
# datasets. These datasets contain indices into the mie_hloswind and rayleigh hloswind datasets to specify which point
# belongs at which level in a profile.

### Mie horizontal line of sight wind profile points ###

print("Individual Mie HLOS wind points")

latitude = coda.fetch(product, 'mie_geolocation', -1, 'windresult_geolocation/latitude_cog')

longitude = coda.fetch(product, 'mie_geolocation', -1, 'windresult_geolocation/longitude_cog')

altitude = coda.fetch(product, 'mie_geolocation', -1, 'windresult_geolocation/altitude_vcog')

mie_wind_velocity = coda.fetch(product, 'mie_hloswind', -1, 'windresult/mie_wind_velocity')

print(mie_wind_velocity.shape)
print(mie_wind_velocity)

### Rayleigh observation wind profiles points ###

print("Individual Rayleight HLOS wind points")

latitude = coda.fetch(product, 'rayleigh_geolocation', -1, 'windresult_geolocation/latitude_cog')

longitude = coda.fetch(product, 'rayleigh_geolocation', -1, 'windresult_geolocation/longitude_cog')

altitude = coda.fetch(product, 'rayleigh_geolocation', -1, 'windresult_geolocation/altitude_vcog')

rayleigh_wind_velocity = coda.fetch(product, 'rayleigh_hloswind', -1, 'windresult/rayleigh_wind_velocity')

print(rayleigh_wind_velocity.shape)
print(rayleigh_wind_velocity)


### Mie profile definition

print("Mie HLOS wind profiles")

result_id = coda.fetch(product, 'mie_profile', -1, 'l2b_wind_profiles/wind_result_id_number')
result_id = vstack(result_id)
# populate wind_velocity profiles (using 0 for unavailable points)
wind_velocity = zeros(result_id.shape)
wind_velocity[result_id != 0] = mie_wind_velocity[result_id[result_id != 0] - 1]
print(wind_velocity.shape)
print(wind_velocity)
print(wind_velocity[result_id != 0])

### Rayleigh profile definition

print("Rayleigh HLOS wind profiles")

result_id = coda.fetch(product, 'rayleigh_profile', -1, 'l2b_wind_profiles/wind_result_id_number')
result_id = vstack(result_id)
# populate wind_velocity profiles (using 0 for unavailable points)
wind_velocity = zeros(result_id.shape)
wind_velocity[result_id != 0] = rayleigh_wind_velocity[result_id[result_id != 0] - 1]
print(wind_velocity.shape)
print(wind_velocity)
print(wind_velocity[result_id != 0])

coda.close(product)
