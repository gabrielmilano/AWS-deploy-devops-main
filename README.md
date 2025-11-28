# AWS-deploy-devops-main

# DevOps – Strapi + Playwright + CI/CD

Projeto utilizado na disciplina de DevOps para demonstrar:

- Subida local de uma API Strapi.  
- Testes end‑to‑end com Playwright em múltiplos navegadores. [web:63]  
- Pipeline de CI/CD com GitHub Actions, preparada para build Docker e deploy via Terraform em AWS (parte de AWS parcialmente configurada). [web:57][web:70]

---

## Tecnologias principais

- **Node.js / npm** – gerenciamento de dependências. [web:62]  
- **Strapi** – Headless CMS que expõe API para o frontend. [web:68]  
- **Playwright** – testes E2E em Chromium, Firefox e WebKit. [web:63]  
- **Docker** – containerização da aplicação (build planejado em pipeline). [web:57]  
- **Terraform** – IaC para provisionar infraestrutura na AWS. [web:70]  
- **GitHub Actions** – automação de testes, build e deploy. [web:57]

---

## 1. Como rodar o Strapi localmente

Pré‑requisitos:

- Node.js LTS instalado.  
- npm instalado (vem junto com o Node). [web:62]

Passos:

1. Clonar o repositório
git clone https://github.com/<seu-usuario>/AWS-deploy-devops-main.git
cd AWS-deploy-devops-main

2. Instalar dependências
npm install

3. Subir o Strapi em modo desenvolvimento
npm run develop

text

O painel administrativo ficará disponível em:

- `http://localhost:1337/admin`  

Na primeira execução é necessário criar o usuário administrador (e-mail e senha). [web:68]

---

## 2. Configurações importantes do Strapi

Alguns ajustes foram feitos para permitir a inicialização local sem depender de variáveis de ambiente externas.

### 2.1 `config/server.ts`

Arquivo responsável pela configuração do servidor Strapi, incluindo as `app.keys` usadas pela middleware de sessão. [web:71]

export default ({ env }) => ({
host: env('HOST', '0.0.0.0'),
port: env.int('PORT', 1337),
app: {
keys: env.array('APP_KEYS', ['myKeyA', 'myKeyB']),
},
});

text

### 2.2 `config/admin.ts`

Arquivo que configura o painel admin, incluindo `apiToken.salt` e `ADMIN_JWT_SECRET`, necessários para tokens de API e autenticação do painel. [web:82][web:100]

export default ({ env }) => ({
auth: {
secret: env('ADMIN_JWT_SECRET', 'dummy-admin-jwt-secret'),
},
apiToken: {
salt: env('API_TOKEN_SALT', 'dummy-api-token-salt'),
},
});

text

Esses valores podem (e devem) ser movidos para variáveis de ambiente em ambientes de produção. [web:86]

---

## 3. Testes end‑to‑end com Playwright

Os testes E2E validam a abertura do painel admin do Strapi em múltiplos navegadores. [web:63]

### 3.1 Instalação dos browsers do Playwright

npx playwright install

text

### 3.2 Execução dos testes

Com o Strapi rodando em `http://localhost:1337/admin`:

npx playwright test

text

O teste principal está em `e2e-tests/example.spec.ts` e verifica se o painel admin abre corretamente:

- Acessa `http://localhost:1337/admin`.  
- Confere se a URL contém `/admin`.  

O relatório HTML pode ser aberto executando:

npx playwright show-report

text

E será exibido em uma URL local como `http://localhost:9323`. [web:63]

---

## 4. Docker (local e pipeline)

### 4.1 Dockerfile

O projeto contém um `Dockerfile` na raiz configurado para:

- Usar uma imagem base Node.  
- Copiar o código do projeto.  
- Instalar dependências com `npm install`.  
- Definir o comando de inicialização da aplicação. [web:57]

De forma simplificada, o build local pode ser feito com:

docker build -t devops-strapi-local .

text

Obs.: na máquina de desenvolvimento ocorreu problema de inicialização do Docker Desktop devido a erro com WSL2, portanto o build local não foi concluído, mas o Dockerfile está pronto para ser usado em ambientes com Docker funcional. [web:57]

### 4.2 Docker na pipeline

O GitHub Actions está configurado para, em ambiente de CI:

- Fazer checkout do código.  
- Instalar dependências e rodar testes Playwright.  
- Realizar `docker build` e (quando configurado) `docker push` para um registry (Docker Hub ou ECR). [web:57]

Isso garante que a etapa de containerização pode ser executada fora da máquina de desenvolvimento, diretamente nos runners da pipeline.

---

## 5. Terraform + AWS (estado atual)

A pasta `terraform/` contém a definição de infraestrutura como código para provisionar recursos na AWS (por exemplo, ECS, ECR, ALB, security groups, etc.). [web:70][web:74]

### 5.1 O que foi configurado

- Criação de usuário IAM específico para CI/CD. [attached_file:24]  
- Definição de secrets no GitHub (`AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, `AWS_REGION`) para permitir autenticação da pipeline na AWS. [attached_file:24]  
- Workflow do GitHub Actions preparado para executar:

  - `terraform init`  
  - `terraform plan`  
  - `terraform apply -auto-approve`  

quando acionado via push/PR ou manualmente. [web:34]

### 5.2 O que não foi finalizado

- Execução completa do `terraform apply` até o fim, devido a limitações de tempo/configuração de conta.  
- Validação final dos recursos criados (ECS Service, Load Balancer com URL pública, etc.). [web:74]

Mesmo assim, o projeto já demonstra:

- Estrutura de IaC organizada.  
- Integração de Terraform com a pipeline (pronta para ser ativada).  

---

## 6. GitHub Actions – Fluxo de CI/CD

Os workflows em `.github/workflows/` foram desenhados para:

1. Disparar em `push` e/ou `pull_request`.  
2. Executar pipeline de:

   - Instalação de dependências (`npm install`).  
   - Execução de testes (`npx playwright test`).  
   - Build de imagem Docker.  
   - (Opcional) Deploy com Terraform na AWS.

Com isso, o fluxo esperado é:

1. Desenvolvedor abre PR com código novo.  
2. Actions rodam testes Playwright.  
3. Se os testes passam, a imagem Docker é construída.  
4. Quando Terraform for habilitado, a infra na AWS é atualizada automaticamente. [web:57][web:70]

---

## 7. Próximos passos sugeridos

- Finalizar a execução do Terraform (`terraform apply`) em uma conta AWS de testes. [web:70]  
- Configurar ECR e ajustar o workflow para fazer `docker push` da imagem do Strapi. [web:74]  
- Adicionar mais testes E2E cobrindo criação de conteúdo (collections) no Strapi. [web:63]  
- Externalizar todas as chaves sensíveis (`APP_KEYS`, `API_TOKEN_SALT`, `ADMIN_JWT_SECRET`) para variáveis de ambiente em produção. [web:86]
