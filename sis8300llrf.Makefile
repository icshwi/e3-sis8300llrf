#
#  Copyright (c) 2018 - 2019  European Spallation Source ERIC
#
#  The program is free software: you can redistribute
#  it and/or modify it under the terms of the GNU General Public License
#  as published by the Free Software Foundation, either version 2 of the
#  License, or any newer version.
#
#  This program is distributed in the hope that it will be useful, but WITHOUT
#  ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
#  FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
#  more details.
#
#  You should have received a copy of the GNU General Public License along with
#  this program. If not, see https://www.gnu.org/licenses/gpl-2.0.txt
#
#
# Author  : joaopaulomartins
#           Jeong Han Lee
# email   : joaopaulomartins@esss.se
#           jeonghan.lee@gmail.com
# Date    : Tuesday, April  2 16:55:14 CEST 2019
# version : 0.0.2
#
where_am_I := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))
include $(E3_REQUIRE_TOOLS)/driver.makefile
include $(E3_REQUIRE_CONFIG)/DECOUPLE_FLAGS


ifneq ($(strip $(ASYN_DEP_VERSION)),)
asyn_VERSION=$(ASYN_DEP_VERSION)
endif

ifneq ($(strip $(LOKI_DEP_VERSION)),)
loki_VERSION=$(LOKI_DEP_VERSION)
endif

ifneq ($(strip $(NDS_DEP_VERSION)),)
nds_VERSION=$(NDS_DEP_VERSION)
endif

ifneq ($(strip $(SIS8300_DEP_VERSION)),)
sis8300_VERSION=$(SIS8300_DEP_VERSION)
endif

ifneq ($(strip $(SIS8300DRV_DEP_VERSION)),)
sis8300drv_VERSION=$(SIS8300DRV_DEP_VERSION)
endif

ifneq ($(strip $(SIS8300LLRFDRV_DEP_VERSION)),)
sis8300llrfdrv_VERSION=$(SIS8300LLRFDRV_DEP_VERSION)
endif


# print cc1plus: warning: unrecognized command line option ‘-Wno-format-truncation’ with lower gcc 7
USR_CFLAGS   += -Wno-format-truncation -std=c++11
USR_CPPFLAGS += -Wno-format-truncation -std=c++11



APP:=.
APPDB:=$(APP)/db
APPSRC:=$(APP)/src

HEADERS += $(wildcard $(APPSRC)/*.h)
SOURCES += $(wildcard $(APPSRC)/*.cpp)

#DBDS  += sis8300llrf-procedure.dbd


TEMPLATES += $(wildcard $(APPDB)/*.template)
TEMPLATES += $(APPDB)/sis8300llrf.db
TEMPLATES += $(APPDB)/sis8300llrf-SpecOp.db
TEMPLATES += $(APPDB)/sis8300llrf-Register.db
TEMPLATES += $(APPDB)/sis8300llrf-Setup.db
## SYSTEM LIBS 
##


ifeq ($(T_A),linux-ppc64e6500)
USR_INCLUDES += -I$(SDKTARGETSYSROOT)/usr/include/libxml2
#USR_INCLUDES += -I$(SDKTARGETSYSROOT)/usr/include/boost
else ifeq ($(T_A),linux-corei7-poky)
USR_INCLUDES += -I$(SDKTARGETSYSROOT)/usr/include/libxml2
#USR_INCLUDES += -I$(SDKTARGETSYSROOT)/usr/include/boost
else
USR_INCLUDES += -I/usr/include/libxml2
#USR_INCLUDES += -I/usr/include/boost
endif

#USR_LIBS += boost_regex
USR_LIBS += xml2

#

USR_DBFLAGS += -I . -I ..
USR_DBFLAGS += -I $(EPICS_BASE)/db
USR_DBFLAGS += -I $(APPDB)

USR_DBFLAGS += -I $(E3_SITELIBS_PATH)/sis8300_$(SIS8300_DEP_VERSION)_db



SUBS=$(wildcard $(APPDB)/*.substitutions)
TMPS=$(wildcard $(APPDB)/*.template)

db: $(SUBS) $(TMPS)

$(SUBS):
	@printf "Inflating database ... %44s >>> %40s \n" "$@" "$(basename $(@)).db"
	@rm -f  $(basename $(@)).db.d  $(basename $(@)).db
	@$(MSI) -D $(USR_DBFLAGS) -o $(basename $(@)).db -S $@  > $(basename $(@)).db.d
	@$(MSI)    $(USR_DBFLAGS) -o $(basename $(@)).db -S $@

$(TMPS):
	@printf "Inflating database ... %44s >>> %40s \n" "$@" "$(basename $(@)).db"
	@rm -f  $(basename $(@)).db.d  $(basename $(@)).db
	@$(MSI) -D $(USR_DBFLAGS) -o $(basename $(@)).db $@  > $(basename $(@)).db.d
	@$(MSI)    $(USR_DBFLAGS) -o $(basename $(@)).db $@


.PHONY: db $(SUBS) $(TMPS)


#
.PHONY: vlibs
vlibs:
#
