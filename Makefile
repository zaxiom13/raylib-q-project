CC := cc
CFLAGS := $(shell pkg-config --cflags raylib)
LDFLAGS := $(shell pkg-config --libs raylib)
KXVER := 3

HELLO_TARGET := hello_window
HELLO_SRC := hello_window.c
Q_SHIM_TARGET := raylib_q_window
Q_SHIM_SRC := raylib_q_window.c
Q_RUNTIME_TARGET := raylib_q_runtime.so
Q_RUNTIME_SRC := raylib_q_runtime.c
Q_INIT_TARGET := raylib_q_init.q
Q_INIT_BUILD := scripts/build_raylib_q_init.sh
Q_INIT_ORDER := qsrc/modules.list
Q_INIT_MODULES := $(shell cat $(Q_INIT_ORDER))
Q_INIT_PARTS := $(addprefix qsrc/,$(Q_INIT_MODULES))

KX_HOME := $(HOME)/.kx
KX_CONFIG := $(KX_HOME)/config
KX_QINIT := $(KX_HOME)/raylib_q_init.q
KX_Q_SHIM := $(KX_HOME)/bin/raylib_q_window
KX_M64 := $(KX_HOME)/m64
KX_Q_RUNTIME := $(KX_M64)/raylib_q_runtime.so

.PHONY: all run test install clean

all: $(HELLO_TARGET) $(Q_SHIM_TARGET) $(Q_RUNTIME_TARGET) $(Q_INIT_TARGET)

$(HELLO_TARGET): $(HELLO_SRC)
	$(CC) $(HELLO_SRC) -o $(HELLO_TARGET) $(CFLAGS) $(LDFLAGS)

$(Q_SHIM_TARGET): $(Q_SHIM_SRC)
	$(CC) $(Q_SHIM_SRC) -o $(Q_SHIM_TARGET) $(CFLAGS) $(LDFLAGS)

$(Q_RUNTIME_TARGET): $(Q_RUNTIME_SRC) k.h
	$(CC) -DKXVER=$(KXVER) $(CFLAGS) -bundle -undefined dynamic_lookup $(Q_RUNTIME_SRC) -o $(Q_RUNTIME_TARGET) $(LDFLAGS)

$(Q_INIT_TARGET): $(Q_INIT_BUILD) $(Q_INIT_ORDER) $(Q_INIT_PARTS)
	$(Q_INIT_BUILD)

run: $(HELLO_TARGET)
	./$(HELLO_TARGET)

test: $(Q_RUNTIME_TARGET) $(Q_INIT_TARGET)
	mkdir -p "$(KX_M64)"
	install -m 755 "$(Q_RUNTIME_TARGET)" "$(KX_Q_RUNTIME)"
	bash "$(Q_INIT_BUILD)" && rm -f /tmp/raylib_q_events_test.txt && q tests/raylib_q_init_tests.q 2>&1

install: $(Q_SHIM_TARGET) $(Q_RUNTIME_TARGET) $(Q_INIT_TARGET)
	mkdir -p "$(KX_HOME)/bin"
	mkdir -p "$(KX_M64)"
	install -m 755 "$(Q_SHIM_TARGET)" "$(KX_Q_SHIM)"
	install -m 755 "$(Q_RUNTIME_TARGET)" "$(KX_Q_RUNTIME)"
	install -m 644 "$(Q_INIT_TARGET)" "$(KX_QINIT)"
	@if [ -f "$(KX_CONFIG)" ]; then \
		if grep -q '^QINIT=' "$(KX_CONFIG)"; then \
			sed -i '' 's|^QINIT=.*|QINIT=$(KX_QINIT)|' "$(KX_CONFIG)"; \
		else \
			printf '\nQINIT=%s\n' "$(KX_QINIT)" >> "$(KX_CONFIG)"; \
		fi; \
	else \
		printf 'QINIT=%s\n' "$(KX_QINIT)" > "$(KX_CONFIG)"; \
	fi
	@echo "Installed raylib shim to $(KX_Q_SHIM)"
	@echo "Configured q startup via $(KX_CONFIG)"

clean:
	rm -f $(HELLO_TARGET) $(Q_SHIM_TARGET) $(Q_RUNTIME_TARGET)
