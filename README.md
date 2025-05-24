# RISCuinho New Generation (RISCuinho-NG)

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
