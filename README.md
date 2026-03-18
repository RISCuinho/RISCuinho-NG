# RISCuinho New Generation (RISCuinho-NG)


![visitors](https://visitor-badge.laobi.icu/badge?page_id=RISCuinho.RISCuinho-NG)
[![License: CC BY-SA 4.0](https://img.shields.io/badge/License-CC_BY--SA_4.0-blue.svg)](https://creativecommons.org/licenses/by-sa/4.0/)
![Language: Portuguese](https://img.shields.io/badge/Language-Portuguese-brightgreen.svg)
![Verilog](https://img.shields.io/badge/Verilog-HDL-blue)
![FPGA](https://img.shields.io/badge/FPGA-Gowin-green)
![Toolchain](https://img.shields.io/badge/Toolchain-Opensource-orange)
![Status](https://img.shields.io/badge/Status-Funcional-brightgreen)


Projeto em Verilog de um microcontrolador dual-core baseado em RISC-V, otimizado para uso com FreeRTOS. Características principais:

- **Dois cores RISC-V** compartilhando memória RAM.
- **Gerenciador de interrupções estilo NVIC** (um por core).
- **Coprocessador de ponto flutuante (FPU)** compartilhado.
- **Testes automatizados** com Icarus Verilog (iverilog).
- **Configuração do GTKwave** para análise de sinais.

## Estrutura do Projeto
- `src/` - Códigos-fonte Verilog dos módulos principais.
- `sim/` - Testbenches, scripts de simulação e arquivos de configuração do GTKwave.
- `docs/` - Documentação técnica e diagramas.
- `Makefile` - Automatização das tarefas de build, simulação e visualização.

## Como rodar os testes

Instale o Python 3, e crie um ambiente Virtual para ele, depois instale o riscv32-unknown-elf, certifiquese que o MakeFile está com o caminho correto onde o riscv32-unknown-elf foi instalado.

```sh
make sim
make gtkwave
```

## Dependências
- iverilog
- gtkwave

## Licença
MIT
