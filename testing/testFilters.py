#!/usr/bin/env python3

import unittest
import time
from math import exp, cos, sin, pi, nan
from glob import glob
from os import system, popen, environ
from random import random, randint

BASE_BOARD="/dev/sis8300"
REG_NOTCH1="0x43f"
REG_NOTCH2="0x440"
REG_NOTCH3="0x441" # enable/disable

REG_LP1="0x442"
REG_LP2="0x443"
REG_LP3="0x444" # enable/disable

PV_NOTCH_FREQ=":NOTCHFIL-FREQ"
PV_NOTCH_BWIDTH=":NOTCHFIL-BWIDTH"
PV_NOTCH_EN=":NOTCHFIL-EN"

PV_LP_EN=":CAVLPFIL-EN"
PV_LP_CUTOFF=":CAVLPFIL-CUTOFF"

PV_F_SAMP=":F-SAMPLING"
PV_N=":IQSMPL-NEARIQN"


def getNumBoard(b):
    """Get then number of a board string"""
    return int(b.split("-")[1])

def getBoard(n = 0):
    """Return the path to board on system"""
    boards = (glob(BASE_BOARD + "*"))
    boards.sort(key=getNumBoard)
    return (boards[n])

def readReg(board, reg):
    p = popen("sis8300drv_reg %s %s" % (board, reg))
    ret = p.read().split("\n")[0]
    p.close()

    return ret


def float2Qmn(val, m, n, signed):
    pow_2_frac_bits = float(0x1 << n)
    pow_2_frac_bits_int_bits = float(0x1 << (m + n))

    val_int64 = int(val * pow_2_frac_bits)
    # Check if signed
    if (signed): 
        if (val_int64 < 0):
            val_int64 += int(pow_2_frac_bits_int_bits)
        # check upper limit of signed int
        elif (val_int64 > (pow_2_frac_bits_int_bits / 2.0 - 1.0)): 
            return nan

    if (val_int64 >> m + n):
        return nan

    return val_int64

class TestLowPass(unittest.TestCase):
    def __init__(self, *args, **kw):
        super().__init__(*args, **kw)
        self.board = getBoard()
        self.PV = environ.get("LLRF_IOC_NAME") + "1"

    def calc_consts(self, cutoff, fsamp, n):
        omg0 = 2*pi*cutoff 
        h = 1/(fsamp/n)

        constA = round(-exp(-omg0*h), 12)
        constB = round(1 - exp(-omg0*h), 12)

        return [constA, constB]

    def test_enable(self):
        """Test Low Pass filter enable/disable"""
        system("caput %s %f > /dev/null" % (self.PV + PV_LP_EN, 1))
        res = readReg(self.board, REG_LP3)

        self.assertEqual(res, "0x1")

        system("caput %s %f > /dev/null" % (self.PV + PV_LP_EN, 0))
        res = readReg(self.board, REG_LP3)

        self.assertEqual(res, "0x0")

    def test_randValues(self):
        """Test Low Pass filter with random values"""
        cutoff = random()*10
        fsamp = round(random()*100 + 100, 2)
        n = float(randint(1,10))

        system("caput %s %f > /dev/null" % (self.PV + PV_LP_CUTOFF, cutoff))
        system("caput %s %f > /dev/null" % (self.PV + PV_F_SAMP, fsamp))
        system("caput %s %f > /dev/null" % (self.PV + PV_N, n))

        res = self.calc_consts(cutoff, fsamp, n)

        a = float2Qmn(res[0], 1, 15, 1)
        self.assertNotEqual(a, nan)
        b = float2Qmn(res[1], 1, 15, 1)
        self.assertNotEqual(b, nan)
        
        a = hex(a)
        b = hex(b)
    
        reg1 = readReg(self.board, REG_LP1)
        self.assertEqual(str(a), reg1)

        reg2 = readReg(self.board, REG_LP2)
        self.assertEqual(str(b), reg2)


class TestNotch(unittest.TestCase):
    def __init__(self, *args, **kw):
        super().__init__(*args, **kw)
        self.board = getBoard()
        # TODO: after fix LLRF_IOC_NAME change this
        self.PV = environ.get("LLRF_IOC_NAME") + "1"

    # calculate and return constants from Notch
    def calc_consts(self, bd, freq, fsamp, n):
        h = 1/(fsamp/n);
        omg0 = 2*pi*freq;
        xi0 = bd/(2*freq);

        areal = round(exp(-(xi0*omg0*h))*cos(omg0*h), 12)
        aimag = round(exp(-(xi0*omg0*h))*sin(omg0*h), 12)
        breal = round((1-exp(-(xi0*omg0*h)))*cos(omg0*h), 12)
        bimag = round((1-exp(-(xi0*omg0*h)))*sin(omg0*h), 12)

        return([areal, aimag, breal, bimag])
       
    def test_randValues(self):
        """Test Notch filter with random values"""
        freq = random()*10
        bwidth = random()*10
        fsamp = round(random()*100 + 100, 2)
        n = float(randint(1,10))

        system("caput %s %f > /dev/null" % (self.PV + PV_NOTCH_FREQ, freq))
        system("caput %s %f > /dev/null" % (self.PV + PV_NOTCH_BWIDTH, bwidth))
        system("caput %s %f > /dev/null" % (self.PV + PV_F_SAMP, fsamp))
        system("caput %s %f > /dev/null" % (self.PV + PV_N, n))

        res = self.calc_consts(bwidth, freq, fsamp, n)

        areal = float2Qmn(res[0], 1, 15, 1)
        self.assertNotEqual(areal, nan)
        aimag = float2Qmn(res[1], 1, 15, 1)
        self.assertNotEqual(aimag, nan)
        breal = float2Qmn(res[2], 1, 15, 1)
        self.assertNotEqual(breal, nan)
        bimag = float2Qmn(res[3], 1, 15, 1)
        self.assertNotEqual(bimag, nan)

        reg1exp = hex((areal << 16) | aimag)
        reg2exp = hex((breal << 16) | bimag)
    
        reg1 = readReg(self.board, REG_NOTCH1)
        self.assertEqual(str(reg1exp), reg1)

        reg2 = readReg(self.board, REG_NOTCH2)
        self.assertEqual(str(reg2exp), reg2)

    def test_enable(self):
        """Test Notch filter enable/disable"""
        system("caput %s %f > /dev/null" % (self.PV + PV_NOTCH_EN, 1))
        res = readReg(self.board, REG_NOTCH3)

        self.assertEqual(res, "0x1")

        system("caput %s %f > /dev/null" % (self.PV + PV_NOTCH_EN, 0))
        res = readReg(self.board, REG_NOTCH3)

        self.assertEqual(res, "0x0")


if __name__ == "__main__":
    unittest.main(verbosity=2)
