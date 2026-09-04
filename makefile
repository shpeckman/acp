CRYSTAL ?= crystal
BIN     := bin

.PHONY: all spec fmt check clean

all: $(BIN)/echo-agent $(BIN)/echo-client

$(BIN)/echo-agent: examples/echo_agent.cr $(shell find src -name '*.cr')
	@mkdir -p $(BIN)
	$(CRYSTAL) build $< -o $@

$(BIN)/echo-client: examples/echo_client.cr $(shell find src -name '*.cr')
	@mkdir -p $(BIN)
	$(CRYSTAL) build $< -o $@

spec:
	$(CRYSTAL) spec

fmt:
	$(CRYSTAL) tool format src spec examples

check: fmt spec

clean:
	rm -rf $(BIN)