<h1 align="center">
  <img src="https://github.com/user-attachments/assets/cad70e9a-90ce-4ece-a65b-64b69bdb1e91" alt="Hamburgueria XTudo" width="240" height="240"><br>
  <b>Hamburgueria</b>
</h1>


<p align="center">
  <i>Sistema de Gestão para Hamburguerias – Progress OpenEdge</i><br>
  <b>Projeto Final de Treinamento</b>
  <br><br>
  <a">Sobre</a> |
  <a>Funcionalidades</a> |
  <a>Tecnologias</a> |
  <a>Como Executar</a> |
  <a>Demonstração Youtube</a> |
  <a>Configurações para utilizar em outros computadores</a> |
  <a>Autor</a>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Progress%20OpenEdge-ABL-blue?style=flat-square">
  <img src="https://img.shields.io/badge/status-100%25%20concluído-brightgreen?style=flat-square">
</p>

---

<details open>
<summary><b>📑 Sumário</b></summary>

- [🧀 Sobre]
- [🚀 Funcionalidades]
- [🛠️ Tecnologias]
- [🗄️ Modelagem de Dados]
- [📦 Instalação & Execução]
- [🎬 Demonstração Youtube]
- [👤 Autor]
</details>

---

## 🧀 Sobre

<p align="justify">
É um sistema de cadastro, gestão de pedidos e geração de relatórios, criado como projeto final de Progress OpenEdge. Para Hamburguerias que desejam controlar cidades, clientes, produtos, pedidos e itens, com regras de negócio reais e exportação dos dados para integração.
</p>

---

## 🚀 Funcionalidades

- 📋 **Cadastro de cidades, clientes e produtos**
- 📝 **Pedidos e Itens** (vínculo completo, proteção contra exclusão errada)
- 🔒 **Regras de exclusão** (não permite excluir cidades com clientes, produtos vinculados a itens, etc.)
- 🔁 **Navegação avançada**: `<<` `<` `>` `>>`, adicionar, modificar, eliminar, salvar, cancelar, exportar, sair
- 🗃️ **Exportação**: Relatórios em `.CSV` e pedidos em `.JSON` para integração
- 📊 **Relatórios prontos**: Clientes e pedidos
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
- Banco de dados criado nome: `xtudo.db`
- Scripts `.p`, `triggers` e `banco de dados` disponibilizados na pasta do projeto

### <div id="#execução">Rodando o sistema</div

```sh
1. Baixe a pasta com os arquivos disponibilizados no github.
2. Coloque ela dentro da pasta C:.
3. O caminho final terá que ser C:\totvs\workspace\xtudoprojeto.
4. Utilizando o link disponibilizado acima, baixe o progress.
5. Abra o developer Studio.
6. Ele vai pedir para abrir um diretório de workspace, como você já baixou a pasta com os arquivos
e colocou no caminho C:\totvs\workspace\xtudoprojeto esse será o diretório do workspace C:\totvs\workspace.
7. Após colocar o caminho do workspace, clique em Launch.
8. O programa abrirá nessa tela se você seguiu os passos anteriores.
```
<img width="1080" height="720" alt="Captura de tela 2025-08-10 215404" src="https://github.com/user-attachments/assets/f4a69d8b-ecee-4854-abff-9a23a101a951" />

```sh
9. Clique na opção Window do Menu.
10. Selecione a opção de Preferences
```
<img width="1914" height="1026" alt="Captura de tela 2025-08-10 220216" src="https://github.com/user-attachments/assets/8920296e-1f9c-47ea-b161-6cf3bf508897" />

```sh
11. Abrirá essa aba.
12. Dentro de Preferences você irá em Startup
```
<img width="1913" height="1025" alt="Captura de tela 2025-08-10 220335" src="https://github.com/user-attachments/assets/a6dc29e9-9520-4036-a34a-36f397f25c44" />

```sh
13. No seu campo Default Startup Parameters,
provavelmente estará assim: -debugalert -inp 16000 -tok 4000 -rereadnolock -s 200 -mmax 65534 .
14. Você irá adicionar mais alguns itens e ficará assim: -debugalert -inp 16000 -tok 4000 -rereadnolock -s 200 -mmax 65534 -h 80 -d dmy -E -T c:\totvs

Significado:
-h 80 = número de bases que podem ser conectadas juntas.
-d dmy = formato de data (-d dmy).
-T c:\totvs = diretório dos arquivos temporários.

15. Após fazer a alteração, é só clicar em "Apply and Close".
```
<img width="1916" height="1027" alt="Captura de tela 2025-08-10 220615" src="https://github.com/user-attachments/assets/4746f8c1-a2cf-421a-a057-50f34ae6c765" />

```sh
16. Seguindo para a conexão com o banco de dados.
17. Clique na pasta principal do projeto com o botão direito do mouse
e selecione a opção Properties(Propriedades).
```
<img width="1472" height="952" alt="Captura de tela 2025-08-10 215842" src="https://github.com/user-attachments/assets/5cab91e2-46ff-4799-9618-e7063383175b" />

```sh
18. Dentro de propriedades você irá na opção Database Connections.
19. Dentro de Database Connections, clique em Configure Database Connections.
```
<img width="1918" height="1028" alt="Captura de tela 2025-08-10 221216" src="https://github.com/user-attachments/assets/a91ae54a-4ac0-4f1a-b4cf-8c621ecf47e3" />

```sh
20. Abrirá essa aba.
21. Clique em New
```
<img width="1917" height="1029" alt="Captura de tela 2025-08-10 221353" src="https://github.com/user-attachments/assets/c43c92b0-74df-4003-8e09-8c9bbf21b86a" />

```sh
20. Abrirá essa aba.
21. Clique em New
22. Abrirá essa página, é só preencher com os dados.
23. O Physical Name será o caminho do banco de dados,
se você seguiu tudo certo o caminho será C:\totvs\xtudo.db.
24. Após preencher tudo, clique em test connection.
25. Se estiver tudo certo, ele mostrará a mensagem "Connection Succeeded".
```
<img width="1917" height="1029" alt="Captura de tela 2025-08-10 221457" src="https://github.com/user-attachments/assets/6205562c-f4db-4d54-bd00-d41230cf7d4f" />
<img width="1917" height="1029" alt="Captura de tela 2025-08-10 221534" src="https://github.com/user-attachments/assets/ad7e8b99-b06d-46aa-8916-2f481e1535e9" />
<img width="1918" height="1031" alt="Captura de tela 2025-08-10 221734" src="https://github.com/user-attachments/assets/01d72e7a-1f38-4d13-ae53-8e76c3d47844" />

```sh
26. Após isso clique em Next.
27. Na próxima parte desabilite Define SQL Connection.
28. Next novamente
```
<img width="1918" height="1028" alt="Captura de tela 2025-08-10 221912" src="https://github.com/user-attachments/assets/5a7507ed-2361-4d65-a2ca-dc3307117caf" />

```sh
29. Agora preencha o campo Service/Port, coloque alguma porta que não esteja em uso.
30. Habilite Auto-Shutdown database server.
31. Clique em Finish.
```
<img width="1918" height="1031" alt="Captura de tela 2025-08-10 222018" src="https://github.com/user-attachments/assets/ae17c749-bce9-42c8-aa8f-aadd73b5605f" />

```sh
32. Você será enviado para essa página, onde estará mostrando o banco de dados.
33. Clique "Apply and Close".
```
<img width="1916" height="1030" alt="Captura de tela 2025-08-10 222205" src="https://github.com/user-attachments/assets/d64ddc82-2fed-42be-a5d1-116274b5ae4a" />

```sh
34. Você virá para essa página, selecione "Show All"
se o seu banco não está sendo mostrado.
35. Selecione o banco de dados.
36. E clique "Apply and Close".
37. Pronto, o banco estará conectado
```
<img width="1918" height="1027" alt="Captura de tela 2025-08-10 222321" src="https://github.com/user-attachments/assets/6c0f5394-9e80-4c3f-a5ea-b6bc0485d7d6" />

```sh
38. Agora clique duas vezes no arquivo menu.p para abrir.
39. Após abrir o arquivo, clique nele com o botão direito e vá em Run As
e selecione a primeira opção.
```
<img width="1918" height="1026" alt="Captura de tela 2025-08-10 222637" src="https://github.com/user-attachments/assets/61b3a909-557b-4de1-8fea-9e33aaabf909" />

```sh
40. Abrirá o menu e você estará rodando meu programa.
```
<img width="1918" height="1029" alt="Captura de tela 2025-08-10 222801" src="https://github.com/user-attachments/assets/6c2a46e7-4689-47e5-af26-8920e91e3c81" />

```sh
41. Veja a demonstração no Youtube:
```
https://youtu.be/NyGHx6vTDac

# Configurações para utilizar em outros computadores.

## Alterações que podem ser Necessárias
```sh
Para executar o projeto em outros locais, pode ser que precise ajustar caminhos.

1️⃣ Arquivo menu.p
Nas linhas 28, 31, 34, 37 estão localizados a ligação dos programas externos que compõem o programa de gerenciamento,
pode ser que para funcionar você tenha que alterar o caminhos da chamada do programa.

Atual:
RUN cidades.p

Alterar de acordo com seu caminho
RUN /caminho/para/seu/projeto/cidades.p.

2️⃣ Arquivo clientes.p
Na linha 53

Atual:
RUN consultarcidades.p

Alterar de acordo com seu caminho
RUN /caminho/para/seu/projeto/consultarcidades.p

3️⃣ Arquivo clientes.p
Na linha 53

Atual:
RUN consultarcidades.p

Alterar de acordo com seu caminho
RUN /caminho/para/seu/projeto/consultarcidades.p

4️⃣ Arquivo pedidos.p
Na linha 69

Atual:
RUN consultarclientes.p

Alterar de acordo com seu caminho
RUN /caminho/para/seu/projeto/consultarclientes.p
```

## Configuração do PROPATH
```sh
O arquivo .propath já está configurado para utilizar variáveis de ambiente, facilitando a portabilidade:

@{ROOT} → Diretório raiz do projeto
@{WORK} → Diretório de trabalho
```




## 👤 Autor
<table> <tr> <td align="center"> <img src="https://avatars.githubusercontent.com/u/209710448?v=4" width="80;" alt=""/> <br /> <b>Caio Rodrigues</b> <br /> <sub>Engenheiro de Software</sub> </td> </tr> </table>
<div>Trabalho desenvolvido para treinamento Progress OpenEdge – 2025</div>
<div><b>Entre em contato: caioh.310306@gmail.com</b></div>

