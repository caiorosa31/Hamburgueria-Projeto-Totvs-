<h1 align="center">
  <img src="https://github.com/user-attachments/assets/cad70e9a-90ce-4ece-a65b-64b69bdb1e91" alt="Hamburgueria XTudo" width="240" height="240"><br>
  <b>Hamburgueria</b>
</h1>


<p align="center">
  <i>Sistema de Gestão para Hamburguerias – Progress OpenEdge</i><br>
  <b>Projeto Final de Treinamento</b>
  <br><br>
  <a href="#sobre">Sobre</a> |
  <a href="#funcionalidades">Funcionalidades</a> |
  <a href="#tecnologias">Tecnologias</a> |
  <a href="#execução">Como Executar</a> |
  <a href="#estrutura">Estrutura</a> |
  <a href="#autor">Autor</a>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Progress%20OpenEdge-ABL-blue?style=flat-square">
  <img src="https://img.shields.io/badge/status-100%25%20concluído-brightgreen?style=flat-square">
</p>

---

<details open>
<summary><b>📑 Sumário</b></summary>

- [🧀 Sobre](#sobre)
- [🚀 Funcionalidades](#funcionalidades)
- [🛠️ Tecnologias](#tecnologias)
- [🗄️ Modelagem de Dados](#Modelagem)
- [📦 Instalação & Execução](#execução)
- [📂 Estrutura de Pastas](#estrutura)
- [👤 Autor](#autor)
</details>

---

## 🧀 Sobre

<p align="justify">
É um sistema completo de cadastro, gestão de pedidos e geração de relatórios, criado como projeto final de Progress OpenEdge. Ideal para hamburguerias/franquias que desejam controlar cidades, clientes, produtos, pedidos e itens, com regras de negócio reais, proteção referencial e exportação dos dados para integração.
</p>

---

## 🚀 Funcionalidades

- 📋 **Cadastro de cidades, clientes e produtos**
- 📝 **Pedidos e Itens** (vínculo completo, proteção contra exclusão errada)
- 🔒 **Regras de exclusão** (não permite excluir cidades com clientes, produtos vinculados a itens, etc.)
- 🔁 **Navegação avançada**: `<<` `<` `>` `>>`, adicionar, modificar, eliminar, salvar, cancelar, exportar, sair
- 🗃️ **Exportação**: Relatórios em `.CSV` e pedidos em `.JSON` para integração
- 📊 **Relatórios prontos**: Clientes, pedidos (por cliente, por data, itens do pedido, valores)
- 🔍 **Validação em todos os cadastros**: Dados obrigatórios, vinculações, e mensagens amigáveis
- 🧑‍💻 **Interface amigável**: Telas de cadastro, navegação e ações padronizadas
- 🔄 **Atualização automática dos browsers** após qualquer operação

---

## 🛠️ Tecnologias

<div align="center">

| Linguagem             | Banco de Dados        | Relatórios/Exportação      | Ambiente       |
|-----------------------|----------------------|----------------------------|---------------|
| **Progress OpenEdge** | Progress OpenEdge DB | CSV, JSON, TXT, Alert-Box  | GUI ABL (4GL) |

</div>

---

## 🗄️ Modelagem de Dados

```plaintext
Cidades   (CodCidade, NomCidade, CodUF)
Clientes  (CodCliente, NomCliente, CodEndereco, CodCidade, Observacao)
Produtos  (CodProduto, NomProduto, ValProduto)
Pedidos   (CodPedido, CodCliente, DatPedido, Observacao)
Itens     (CodPedido, CodItem, CodProduto, NumQuantidade, ValTotal)
```

## 📦 Instalação & Execução

### Pré-requisitos

- Ambiente [Progress OpenEdge](https://www.progress.com/openedge) instalado
- Banco de dados criado (ex: `xtudo.db`)
- Scripts `.p` na pasta do projeto

### Rodando o sistema

```sh
1. Crie o banco de dados vazio (pelo Data Dictionary)
2. Importe/execute os scripts de tabelas e índices
3. Abra o projeto no Progress Developer Studio (ou AppBuilder)
4. Execute o arquivo de menu principal ou qualquer .p do CRUD
5. Navegue pelos cadastros, realize inclusões/alterações e gere relatórios!

```

## 📂 Estrutura de Pastas

```python
/xtudoprojeto
├── cidades.p         # Cadastro de cidades
├── clientes.p        # Cadastro de clientes
├── produtos.p        # Cadastro de produtos
├── pedidos.p         # Cadastro de pedidos e browser de itens
├── itens.p           # Cadastro e manutenção de itens
├── additens.p        # Inclusão de itens (modal)
├── moditens.p        # Alteração de itens
├── deleteitens.p     # Exclusão de itens
├── Trabalho_Final.pdf
└── README.md

```

## 👤 Autor
<table> <tr> <td align="center"> <img src="https://avatars.githubusercontent.com/u/209710448?v=4" width="80;" alt=""/> <br /> <b>Caio Rodrigues</b> <br /> <sub>Engenheiro de Software</sub> </td> </tr> </table>
<div>Trabalho desenvolvido para treinamento Progress OpenEdge – 2025</div>
<div><b>Entre em contato: cioh.310306@gmail.com</b></div>

