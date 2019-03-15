.PHONY: all clean

COMPILER:=eosio-cpp
SRCDIR:=../src/
OBJDIR:=obj/

all: ../chex/token.wasm

doxygen:= ../documentation/doxygen/build
SRC:= $(wildcard ../src/*.cpp) $(wildcard ../tests/*.cpp)
INCLUDES:= $(wildcard ../include/*.hpp)
HEADERS:= $(wildcard ../include/*.hpp)
OBJ:= $(patsubst $(SRCDIR)%.cpp,$(OBJDIR)%.o,$(SRC))

$(OBJDIR):
	mkdir -p $@

../chex/token.wasm: $(SRC) $(INCLUDES)
	@$(COMPILER) ../src/chex.cpp  -I=../include  -I=$(EOSIO_CONTRACT_DIR)/contracts/eosio.system/include  -I=$(EOSIO_CONTRACT_DIR)/contracts/eosio.token/include  -isystem=$(EOSIO_CDT_DIR)/libraries -I=$(BOOST_DIR)/include/  -o $@ -DCOMPILE_WASM -abigen

documentation: | $(doxygen)
	cd ../documentation && doxygen Doxyfile

UNAME := $(shell uname)
DOXYGEN := $(shell doxygen --version)

ifeq ($(UNAME), Linux)
$(doxygen):
	mkdir -p ../documentation/doxygen/build
	sudo apt install flex bison libiconv-hook-dev strip-nondeterminism; mkdir $(doxygen); cd $(doxygen); cmake -G "Unix Makefiles" ..; make -j; sudo make install -j;
endif
ifeq ($(UNAME), Darwin)
ifndef $(DOXYGEN)
$(doxygen):
	mkdir -p ../documentation/doxygen/build
	brew install doxygen
endif
endif

clean:
	rm -f ../chex/*.wasm 
