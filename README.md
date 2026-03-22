# MC613A - Laboratório de Circuitos Digitais (1s2026)

Repositório da disciplina **MC613A - Laboratório de Circuitos Digitais**.

---

## 👥 Alunos

* (195440) Samuel Rodrigues Ferreira
* (274161) Gabriel Vinícius Dos Santos Soares
* (278525) Rafael Henrique de Gaspi
* (281174) Felipe Gayotto Bianchessi
* (288820) Leonardo Carvalho De Luca

---

## 📚 Projetos

### 🧪 P1: Vending Machine

**Status:** Em desenvolvimento

**A fazer:**

* Máquina de Controle
* Testbenches

---

### 🧪 P2: Controlador VGA

**Status:** Ainda não feito

---

### 🧪 P3: Controlador DRAM

**Status:** Ainda não feito

---

### 🧪 P4: Mini-CPU

**Status:** Ainda não feito

---

## ▶️ Simulação (ModelSim)

1. No Quartus, configure e selecione os testbenches em:

```
Settings → EDA Tool Settings → Simulation → NativeLink settings → Compile test bench
```

2. Após abrir o ModelSim, execute no terminal:

```tcl
vsim -voptargs=+acc=n work.file_tb
add wave -r *
run -all
```

> Substitua `file` pelo nome do testbench que deseja rodar.

Isso fará com que as entradas e saídas do testbench apareçam no formato de **ondas (waveform)**, facilitando a análise da simulação.
