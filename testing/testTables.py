#!/usr/bin/env python3

import unittest
from random import random, randint
from os import system, environ, popen

from testFilters import readReg, getBoard, flot2Qmn

NELM = 16
PREC = 15
FF_REG="0x41e"
SP_REG="0x41f"
M_BITS=1
N_BITS=15

MIN_VAL=-2**(M_BITS-1)
MAX_VAL=2**(M_BITS-1) - 2**(-N_BITS)

# Normal mode

# SP - PT0 - I
# SP - PT0 - Q
# FF - PT0 - I
# FF - PT0 - Q 

# Special mode

# SP - SM - I
# SP - SM - Q
# FF - SM - I
# FF - SM - Q 


#epicsFloat32 sis8300llrfControlTableChannel::_FFSPSampleMin =                    
#         (epicsFloat32) (-pow(2, sis8300llrfdrv_Qmn_IQ_sample.int_bits_m - 1));  
#                                                                                 
#epicsFloat32 sis8300llrfControlTableChannel::_FFSPSampleMax =                    
#         (epicsFloat32) (pow(2, sis8300llrfdrv_Qmn_IQ_sample.int_bits_m - 1) -   
#                         pow(2, -(int)sis8300llrfdrv_Qmn_IQ_sample.frac_bits_n));
#

def readMem(board, offset, size):
    p = popen("sis8300drv_mem %s -o %d -n %d" % (board, offset, size))
    ret = p.read()
    p.close()

    return ret


class TestTablesNormal(unittest.TestCase):
    """Class for test tables on Normal mode"""
    def __init__(self, *args, **kw):
        super().__init__(*args, **kw)
        self.board = getBoard()
        self.PV = environ.get("LLRF_IOC_NAME") + "1"

    def set_table(self, ctrl, type, qi, size=16):
        """Set values for one table (the same value)
        ctrl = SP / FF
        type = PT0 / SM
        qi = I / Q
        size = number of elements
        """
        val = round(random()*(MAX_VAL-MIN_VAL)+MIN_VAL, PREC)
        while (val > MAX_VAL or val < MIN_VAL):
            val = round(random()*(MAX_VAL-MIN_VAL)+MIN_VAL, PREC)

        vals = []
        vals.extend([val]*size)
        # let on format to caput
        vals_str = str(size) + " " + (str(vals).replace(",",""))[1:-1]
        
        pv = self.PV + ":" + ctrl + "-" + type

        system("caput -a %s %s > /dev/null " % (pv + "-" + qi, vals_str))

        # write table to the memory
        system("caput %s %d > /dev/null " % (pv + "-WRTBL", 1))

        return val


    def test_tables_sp_qi(self):
        """Test tables SP Q/I"""
        q_val = self.set_table("SP", "PT0", "Q")
        i_val = self.set_table("SP", "PT0", "I")
    
        mem_pos = int(readReg(self.board, SP_REG), NELM)
        mem_values = (readMem(self.board, int(mem_pos/2), NELM*2).split('\n'))[:-1]
        q_val_qmn = str(flot2Qmn(q_val, 1, 15, 1))
        i_val_qmn = str(flot2Qmn(i_val, 1, 15, 1))
       
        # get a random position to check 
        pos = randint(1, 15)
        # q pos = pos*2
        # i pos = pos*2 + 1

        self.assertEqual(q_val_qmn, mem_values[pos*2])
        self.assertEqual(i_val_qmn, mem_values[pos*2+1])

    def test_tables_ff_qi(self):
        """Test tables FF Q/I"""
        q_val = self.set_table("FF", "PT0", "Q")
        i_val = self.set_table("FF", "PT0", "I")
    
        mem_pos = int(readReg(self.board, FF_REG), NELM)
        mem_values = (readMem(self.board, int(mem_pos/2), NELM*2).split('\n'))[:-1]
        q_val_qmn = str(flot2Qmn(q_val, 1, 15, 1))
        i_val_qmn = str(flot2Qmn(i_val, 1, 15, 1))
       
        # get a random position to check 
        pos = randint(1, 15)
        # q pos = pos*2
        # i pos = pos*2 + 1

        self.assertEqual(q_val_qmn, mem_values[pos*2])
        self.assertEqual(i_val_qmn, mem_values[pos*2+1])


if __name__ == "__main__":
    unittest.main(verbosity=2)

