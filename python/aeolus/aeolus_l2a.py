import os

# Change this to the location of your AEOLUS codadef file
os.putenv('CODA_DEFINITION', '/usr/local/share/coda/definitions')
# You can also remove this line and set the CODA_DEFINITION environment variable globally on your system

import coda
from numpy import hstack, vstack

# change this to the full path of your Aeolus L2A DBL file
filename = "/path/to/AE_OPER_ALD_U_N_2A_20071107T193753059_008688000_000578_0001.DBL"

product = coda.open(filename)

### Standard Correct Algorithm (SCA) at middle bins ###

if coda.get_field_available(product, 'sca_optical_properties'):
    print("SCA optical properties at middle bins")
    latitude = coda.fetch(product, 'sca_optical_properties', -1, 'geolocation_middle_bins', -1, 'latitude')
    latitude = vstack(latitude)

    longitude = coda.fetch(product, 'sca_optical_properties', -1, 'geolocation_middle_bins', -1, 'longitude')
    longitude = vstack(longitude)

    altitude = coda.fetch(product, 'sca_optical_properties', -1, 'geolocation_middle_bins', -1, 'altitude')
    altitude = vstack(altitude)

    extinction = coda.fetch(product, 'sca_optical_properties', -1, 'sca_optical_properties_mid_bins', -1, 'extinction')
    extinction = vstack(extinction)
    print(extinction.shape)
    print(extinction)

    backscatter = coda.fetch(product, 'sca_optical_properties', -1, 'sca_optical_properties_mid_bins', -1, 'backscatter')
    backscatter = vstack(backscatter)
    print(backscatter.shape)
    print(backscatter)


### Standard Correct Algorithm (SCA) ###

if coda.get_field_available(product, 'sca_optical_properties'):
    print("SCA optical properties")
    extinction = coda.fetch(product, 'sca_optical_properties', -1, 'sca_optical_properties', -1, 'extinction')
    extinction = vstack(extinction)
    print(extinction.shape)
    print(extinction)

    backscatter = coda.fetch(product, 'sca_optical_properties', -1, 'sca_optical_properties', -1, 'backscatter')
    backscatter = vstack(backscatter)
    print(backscatter.shape)
    print(backscatter)


### Iterative Correct Algorithm (ICA) ###

if coda.get_field_available(product, 'ica_optical_properties'):
    print("ICA optical properties")
    extinction = coda.fetch(product, 'ica_optical_properties', -1, 'ica_optical_properties', -1, 'extinction')
    extinction = vstack(extinction)
    print(extinction.shape)
    print(extinction)

    backscatter = coda.fetch(product, 'ica_optical_properties', -1, 'ica_optical_properties', -1, 'backscatter')
    backscatter = vstack(backscatter)
    print(backscatter.shape)
    print(backscatter)


### Mie Channel Algorithm (MCA) ###

if coda.get_field_available(product, 'mca_optical_properties'):
    print("MCA optical properties")
    extinction = coda.fetch(product, 'mca_optical_properties', -1, 'mca_optical_properties', -1, 'extinction')
    extinction = vstack(extinction)
    print(extinction.shape)
    print(extinction)


coda.close(product)
