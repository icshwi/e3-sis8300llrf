#!/usr/bin/env python3

import unittest
from random import random, randint
from os import system, environ, popen

from testFilters import readReg, getBoard, float2Qmn

NELM = 16
FF_REG="0x41e"
SP_REG="0x41f"

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

def getMinMaxMN(m, n, signed):
    if signed:
        min = -2**(m-1)
        max = 2**(m-1) - 2**(-n)
    else:
        min = 0
        max = (2**m) - (2**(-n))

    return (min, max)

def readMem(board, offset, size):
    p = popen("sis8300drv_mem %s -o %d -n %d" % (board, offset, size))
    ret = p.read()
    p.close()

    return ret

def set_table(pv_base, ctrl, type, qi, qmn, size = 16):
    """Set values for one table (the same value)
    ctrl = SP / FF
    type = PT0 / SM
    qi = I / Q
    size = number of elements
    qmn = (m, n, signed)
    """

    (min, max) = getMinMaxMN(*qmn)

    val = round(random()*(max-min)+min, qmn[2])
    while (val > max or val < min):
        val = round(random()*(max-min)+min, qmn[2])

    vals = []
    vals.extend([val]*size)
    # let on format to caput
    vals_str = str(size) + " " + (str(vals).replace(",",""))[1:-1]
    
    pv = pv_base + ":" + ctrl + "-" + type

    system("caput -a %s %s > /dev/null " % (pv + "-" + qi, vals_str))

    # write table to the memory
    system("caput %s %d > /dev/null " % (pv + "-WRTBL", 1))

    # update readback
    system("caput %s %d > /dev/null " % (pv + "-" + qi + "-GET.PROC", 1))


    return val

class TestTablesNormal(unittest.TestCase):
    """Class for test tables on Normal mode"""
    def __init__(self, *args, **kw):
        super().__init__(*args, **kw)
        self.board = getBoard()
        self.PV = environ.get("LLRF_IOC_NAME") + "1"
        self.qmn = (1, 15, 1)

    def test_tables_sp_qi(self):
        """Test tables SP Q/I on normal mode"""
        q_val = set_table(self.PV, "SP", "PT0", "Q", self.qmn)
        i_val = set_table(self.PV, "SP", "PT0", "I", self.qmn)
    
        mem_pos = int(readReg(self.board, SP_REG), NELM)
        mem_values = (readMem(self.board, int(mem_pos/2), NELM*2).split('\n'))[:-1]
        q_val_qmn = str(float2Qmn(q_val, *self.qmn))
        i_val_qmn = str(float2Qmn(i_val, *self.qmn))
       
        # get a random position to check 
        pos = randint(1, 15)
        # q pos = pos*2
        # i pos = pos*2 + 1

        self.assertEqual(q_val_qmn, mem_values[pos*2])
        self.assertEqual(i_val_qmn, mem_values[pos*2+1])

    def test_tables_ff_qi(self):
        """Test tables FF Q/I on normal mode"""
        q_val = set_table(self.PV, "FF", "PT0", "Q", self.qmn)
        i_val = set_table(self.PV, "FF", "PT0", "I", self.qmn)
    
        mem_pos = int(readReg(self.board, FF_REG), NELM)
        mem_values = (readMem(self.board, int(mem_pos/2), NELM*2).split('\n'))[:-1]
        q_val_qmn = str(float2Qmn(q_val, *self.qmn))
        i_val_qmn = str(float2Qmn(i_val, *self.qmn))
       
        # get a random position to check 
        pos = randint(1, 15)
        # q pos = pos*2
        # i pos = pos*2 + 1

        self.assertEqual(q_val_qmn, mem_values[pos*2])
        self.assertEqual(i_val_qmn, mem_values[pos*2+1])


class TestTablesSpecial(unittest.TestCase):
    """Class for test tables on Normal mode on normal mode"""
    def __init__(self, *args, **kw):
        super().__init__(*args, **kw)
        self.board = getBoard()
        self.PV = environ.get("LLRF_IOC_NAME") + "1"
        self.qmn_ang = (3, 13, 1)
        self.qmn_mag_sp = (0, 16, 0)
        self.qmn_mag_ff = (1, 15, 1)
        self.qmn_qi = (1, 15, 1)

    def test_tables_sp_mag_ang(self):
        """Test tables SP Mag and Ang"""
        ang_val = set_table(self.PV, "SP", "SM", "ANG", self.qmn_ang)
        mag_val = set_table(self.PV, "SP", "SM", "MAG", self.qmn_mag_sp)
    
        mem_pos = int(readReg(self.board, SP_REG), NELM)
        mem_values = (readMem(self.board, int(mem_pos/2), NELM*2).split('\n'))[:-1]
        ang_val_qmn = str(float2Qmn(ang_val, *self.qmn_ang))
        mag_val_qmn = str(float2Qmn(mag_val, *self.qmn_mag_sp))
       
        # get a random position to check 
        pos = randint(0, 15)
        # ang pos = pos*2
        # mag pos = pos*2 + 1

        self.assertEqual(ang_val_qmn, mem_values[pos*2])
        self.assertEqual(mag_val_qmn, mem_values[pos*2+1])

    def test_tables_ff_mag_ang(self):
        """Test tables FF Mag and Ang"""
        ang_val = set_table(self.PV, "FF", "SM", "ANG", self.qmn_ang)
        mag_val = set_table(self.PV, "FF", "SM", "MAG", self.qmn_mag_ff)
    
        mem_pos = int(readReg(self.board, FF_REG), NELM)
        mem_values = (readMem(self.board, int(mem_pos/2), NELM*2).split('\n'))[:-1]
        ang_val_qmn = str(float2Qmn(ang_val, *self.qmn_ang))
        mag_val_qmn = str(float2Qmn(mag_val, *self.qmn_mag_ff))
       
        # get a random position to check 
        pos = randint(0, 15)
        # q pos = pos*2
        # i pos = pos*2 + 1

        self.assertEqual(ang_val_qmn, mem_values[pos*2])
        self.assertEqual(mag_val_qmn, mem_values[pos*2+1])

    def test_tables_sp_qi(self):
        """Test tables SP Q and I """
        q_val = set_table(self.PV, "SP", "SM", "Q", self.qmn_qi)
        i_val = set_table(self.PV, "SP", "SM", "I", self.qmn_qi)
    
        mem_pos = int(readReg(self.board, SP_REG), NELM)
        mem_values = (readMem(self.board, int(mem_pos/2), NELM*2).split('\n'))[:-1]
        q_val_qmn = str(float2Qmn(q_val, *self.qmn_qi))
        i_val_qmn = str(float2Qmn(i_val, *self.qmn_qi))
       
        # get a random position to check 
        pos = randint(0, 15)
        # q pos = pos*2
        # i pos = pos*2 + 1

        self.assertEqual(q_val_qmn, mem_values[pos*2])
        self.assertEqual(i_val_qmn, mem_values[pos*2+1])

    def test_tables_ff_qi(self):
        """Test tables FF Q and I """
        q_val = set_table(self.PV, "FF", "SM", "Q", self.qmn_qi)
        i_val = set_table(self.PV, "FF", "SM", "I", self.qmn_qi)
    
        mem_pos = int(readReg(self.board, FF_REG), NELM)
        mem_values = (readMem(self.board, int(mem_pos/2), NELM*2).split('\n'))[:-1]
        q_val_qmn = str(float2Qmn(q_val, *self.qmn_qi))
        i_val_qmn = str(float2Qmn(i_val, *self.qmn_qi))
       
        # get a random position to check 
        pos = randint(0, 15)
        # q pos = pos*2
        # i pos = pos*2 + 1

        self.assertEqual(q_val_qmn, mem_values[pos*2])
        self.assertEqual(i_val_qmn, mem_values[pos*2+1])

if __name__ == "__main__":
    unittest.main(verbosity=2)

