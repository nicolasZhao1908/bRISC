TESTS := tb/test_dcache \
		tb/test_arbiter \
		tb/test_regfile \
		tb/test_memory \
		tb/test_ram \
		tb/test_alu \
		tb/test_ifetch \
		tb/test_decode \
		tb/test_core

.PHONY: $(TESTS) clean all

all: $(TESTS)

$(TESTS):
	@cd $@ && $(MAKE)

clean:
	$(foreach TEST, $(TESTS), $(MAKE) -C $(TEST) clean;)
