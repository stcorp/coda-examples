# This shows how to read the p/z/t/u off-nadir variables from an AUX_MET_12 file.
#
# Note that reading of AUX_MET_12 data is inherently slow because data is stored as
# 'arrays of records' instead of 'records with fields being arrays'
# Reading would be much faster if the data would be stored as multidimensional arrays for each variable.
#
# As an alternative to the approach below, you could preconvert the data to HDF4 using the codadump tool:
#   $ codadump hdf4 -o output.hdf AE_OPER_AUX_MET_12_20071107T090000_20071108T150000_0001.DBL
# And then just read the data using:
#   product = coda.open('test.hdf')
#   amd_pnom = coda.fetch(product,'/met_off_nadir/profile_data/amd_pnom')
#   amd_znom = coda.fetch(product,'/met_off_nadir/profile_data/amd_znom')
#   amd_t = coda.fetch(product,'/met_off_nadir/profile_data/amd_t')
#   amd_u = coda.fetch(product,'/met_off_nadir/profile_data/amd_u')
#   coda.close(product)
# If you repeatedly need to access data from the same file then this will be orders of magnitude faster.
#

import os

# Change this to the location of your AEOLUS codadef file
os.putenv('CODA_DEFINITION', '/usr/local/share/coda/definitions')
# You can also remove this line and set the CODA_DEFINITION environment variable globally on your system

import coda
import numpy

# change this to the full path of your Aeolus L1B DBL file
filename = "AE_OPER_AUX_MET_12_20071107T090000_20071108T150000_0001.DBL"

product = coda.open(filename)

num_records = coda.fetch(product, '/sph/num_records_in_ds1')
num_layers = coda.fetch(product, '/sph/num_of_model_layers')

assert(num_records > 0 and num_layers > 0)

amd_pnom = numpy.empty([num_records, num_layers])
amd_znom = numpy.empty([num_records, num_layers])
amd_t = numpy.empty([num_records, num_layers])
amd_u = numpy.empty([num_records, num_layers])

cursor = coda.Cursor()
coda.cursor_set_product(cursor, product)
coda.cursor_goto(cursor, '/met_off_nadir[0]')
for i in range(num_records):
    coda.cursor_goto(cursor, 'profile_data[0]')
    for j in range(num_layers - 1):
        coda.cursor_goto(cursor, 'amd_pnom')
        amd_pnom[i,j] = coda.cursor_read_double(cursor)
        coda.cursor_goto(cursor, '../amd_znom')
        amd_znom[i,j] = coda.cursor_read_double(cursor)
        coda.cursor_goto(cursor, '../amd_t')
        amd_t[i,j] = coda.cursor_read_double(cursor)
        coda.cursor_goto(cursor, '../amd_u')
        amd_u[i,j] = coda.cursor_read_double(cursor)
        coda.cursor_goto_parent(cursor)
        coda.cursor_goto_next_array_element(cursor)
    coda.cursor_goto_parent(cursor)
    coda.cursor_goto_parent(cursor)
    if i < num_records - 1:
        coda.cursor_goto_next_array_element(cursor)
del cursor
coda.close(product)

print(amd_pnom)
print(amd_znom)
print(amd_t)
print(amd_u)

