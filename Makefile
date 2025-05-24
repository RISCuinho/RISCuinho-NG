# Makefile para RISCuinho-NG

IVERILOG=iverilog
VVP=vvp
GCC=riscv32-unknown-elf-gcc
OBJCOPY=riscv32-unknown-elf-objcopy
PYTHON=python3

SIM_TOP=sim/riscuinho_ng_top_tb.v
SRC=$(wildcard src/*.v)
VCD=sim/riscuinho_ng_top_tb.vcd

# Lista de algoritmos disponíveis
ALGS=fatorial fibonacci bubblesort quicksort binsearch matmul fft primos bigmul dijkstra test_muldiv test_fpu

# Algoritmo padrão para teste
ALG?=fatorial

all: sim

sim: $(VCD)

$(VCD): $(SIM_TOP) $(SRC) sim/algorithms/mem_init.hex
	$(IVERILOG) -g2012 -o sim/a.out $(SIM_TOP) $(SRC)
	$(VVP) sim/a.out

# Geração do arquivo HEX a partir do algoritmo selecionado
sim/algorithms/mem_init.hex: sim/algorithms/$(ALG).bin
	$(PYTHON) sim/scripts/mem_init.py sim/algorithms/$(ALG).bin sim/algorithms/mem_init.hex

# Compilação dos algoritmos em C
sim/algorithms/%.bin: sim/algorithms/%.c
	$(GCC) -march=rv32im -mabi=ilp32 -nostdlib -Ttext=0x0 -o sim/algorithms/$*.elf $<
	$(OBJCOPY) -O binary sim/algorithms/$*.elf $@

# Compilação dos algoritmos em Assembly
sim/algorithms/%.bin: sim/algorithms/%.S
	$(GCC) -march=rv32im -mabi=ilp32 -nostdlib -Ttext=0x0 -o sim/algorithms/$*.elf $<
	$(OBJCOPY) -O binary sim/algorithms/$*.elf $@

# Target para rodar todos os testes automaticamente
tests: $(ALGS:%=test-%)

# Target para rodar todos os testes com checagem automática
autotest:
	@echo "==> Rodando todos os testes com checagem automática..."
	@$(MAKE) autotest-fatorial
	@$(MAKE) autotest-fibonacci
	@$(MAKE) autotest-bubblesort
	@$(MAKE) autotest-quicksort
	@$(MAKE) autotest-binsearch
	@$(MAKE) autotest-matmul
	@$(MAKE) autotest-fft
	@$(MAKE) autotest-primos
	@$(MAKE) autotest-bigmul
	@$(MAKE) autotest-dijkstra
	@$(MAKE) autotest-test_fpu
	@$(MAKE) autotest-test_muldiv
	@echo "==> Todos os autotestes executados."

# Targets individuais para autotest
autotest-fatorial:
	@echo "[AUTOTEST] FATORIAL"
	$(MAKE) ALG=fatorial VFLAGS='-DTEST_FATORIAL' sim

autotest-fibonacci:
	@echo "[AUTOTEST] FIBONACCI"
	$(MAKE) ALG=fibonacci VFLAGS='-DTEST_FIBONACCI' sim

autotest-bubblesort:
	@echo "[AUTOTEST] BUBBLESORT"
	$(MAKE) ALG=bubblesort VFLAGS='-DTEST_BUBBLESORT' sim

autotest-quicksort:
	@echo "[AUTOTEST] QUICKSORT"
	$(MAKE) ALG=quicksort VFLAGS='-DTEST_QUICKSORT' sim

autotest-binsearch:
	@echo "[AUTOTEST] BINSEARCH"
	$(MAKE) ALG=binsearch VFLAGS='-DTEST_BINSEARCH' sim

autotest-matmul:
	@echo "[AUTOTEST] MATMUL"
	$(MAKE) ALG=matmul VFLAGS='-DTEST_MATMUL' sim

autotest-fft:
	@echo "[AUTOTEST] FFT"
	$(MAKE) ALG=fft VFLAGS='-DTEST_FFT' sim

autotest-primos:
	@echo "[AUTOTEST] PRIMOS"
	$(MAKE) ALG=primos VFLAGS='-DTEST_PRIMOS' sim

autotest-bigmul:
	@echo "[AUTOTEST] BIGMUL"
	$(MAKE) ALG=bigmul VFLAGS='-DTEST_BIGMUL' sim

autotest-dijkstra:
	@echo "[AUTOTEST] DIJKSTRA"
	$(MAKE) ALG=dijkstra VFLAGS='-DTEST_DIJKSTRA' sim

autotest-test_fpu:
	@echo "[AUTOTEST] TEST_FPU"
	$(MAKE) ALG=test_fpu VFLAGS='-DTEST_FPU' sim

autotest-test_muldiv:
	@echo "[AUTOTEST] TEST_MULDIV"
	$(MAKE) ALG=test_muldiv VFLAGS='-DTEST_MULDIV' sim

# Target para cada algoritmo individual
$(ALGS:%=test-%): test-%: sim/algorithms/%.bin
	@echo "==> Testando $*"
	$(PYTHON) sim/scripts/mem_init.py sim/algorithms/$*.bin sim/algorithms/mem_init.hex
	$(IVERILOG) -g2012 -o sim/a.out $(SIM_TOP) $(SRC)
	$(VVP) sim/a.out
	@echo "Abra o resultado com: make wave"

clean:
	rm -f sim/a.out $(VCD) sim/algorithms/*.elf sim/algorithms/*.bin sim/algorithms/*.hex

wave:
	gtkwave $(VCD)

# Exemplo de uso:
# make ALG=test_muldiv sim
# make ALG=test_fpu sim
# make test-matmul
# make tests
