-- =========================|Schemas|============================
-- garantir que data seja imutavel, criando um schema temporario
CREATE SCHEMA IF NOT EXISTS tmp
-- move ela pro temp
ALTER TABLE dw.dim_data SET SCHEMA tmp;
-- dropa o schema
DROP SCHEMA IF EXISTS dw CASCADE;
-- recriar
CREATE SCHEMA dw;
- move de volta a dim_data
ALTER TABLE tmp.dim_data SET SCHEMA dw;
-- dropa schema temporario
DROP SCHEMA IF EXISTS tmp;

-- ================|Tabelas Dimensionais|========================
-- SCD Tipo 0 — Imutável
CREATE TABLE dw.dim_data (
    sk_data INTEGER PRIMARY KEY,
    data_completa DATE NOT NULL,
    dia INTEGER NOT NULL,
    mes INTEGER NOT NULL,
    ano INTEGER NOT NULL,
    trimestre INTEGER NOT NULL,
    semestre INT NOT NULL,
    nome_mes VARCHAR(20),
    dia_semana VARCHAR(20),
    final_semana BOOLEAN
);

-- SCD Tipo 2 — Histórico
CREATE TABLE dw.dim_cliente (
    sk_cliente SERIAL PRIMARY KEY,
    chave_hash TEXT,
    id_cliente INTEGER,
    nome_cliente VARCHAR(100),
    cpf VARCHAR(11),
    email VARCHAR(100),
    telefone VARCHAR(20),
    municipio VARCHAR(100),
    estado VARCHAR(2),

    data_inicio DATE NOT NULL,
    data_fim DATE,
    flag_ativo BOOLEAN
);

-- SCD Tipo 2 — Histórico
CREATE TABLE dw.dim_produto (
    sk_produto SERIAL PRIMARY KEY,
    id_produto INTEGER,
    chave_hash TEXT,
    nome_produto VARCHAR(100),
    descricao_produto VARCHAR(100),
    categoria VARCHAR(50),
    valor_unitario NUMERIC(10,2),

    data_inicio DATE NOT NULL,
    data_fim DATE,
    flag_ativo BOOLEAN
);

-- SCD Tipo 1 — Sobrescrita
CREATE TABLE dw.dim_promocao (
    sk_promocao SERIAL PRIMARY KEY,
    id_promocao INTEGER,
    nome_promocao VARCHAR(100),
    tipo_desconto VARCHAR(20),
    valor_desconto NUMERIC(10,2),
    data_inicio DATE,
    data_fim DATE
);

-- SCD Tipo 1 — Sobrescrita
CREATE TABLE dw.dim_pagamento (
    sk_pagamento SERIAL PRIMARY KEY,
    tipo_pagamento VARCHAR(50)
);

-- SCD Tipo 1 — Sobrescrita
CREATE TABLE dw.dim_status_pedido (
    sk_status SERIAL PRIMARY KEY,
    status_pedido VARCHAR(50)
);

-- ======================|Tabela Fato|===========================
CREATE TABLE dw.fato_vendas (
    sk_venda SERIAL PRIMARY KEY,
    sk_data INTEGER NOT NULL,
    sk_cliente INTEGER NOT NULL,
    sk_produto INTEGER NOT NULL,
    sk_promocao INTEGER,
    sk_pagamento INTEGER,
    sk_status INTEGER,

    quantidade INTEGER NOT NULL,
    preco_base NUMERIC(10,2),
    preco_final NUMERIC(10,2),
    valor_bruto NUMERIC(10,2),
    valor_desconto NUMERIC(10,2),
    valor_liquido NUMERIC(10,2),

    CONSTRAINT fk_data
        FOREIGN KEY (sk_data) REFERENCES dw.dim_data(sk_data),

    CONSTRAINT fk_cliente
        FOREIGN KEY (sk_cliente) REFERENCES dw.dim_cliente(sk_cliente),

    CONSTRAINT fk_produto
        FOREIGN KEY (sk_produto) REFERENCES dw.dim_produto(sk_produto),

    CONSTRAINT fk_promocao
        FOREIGN KEY (sk_promocao) REFERENCES dw.dim_promocao(sk_promocao),

    CONSTRAINT fk_pagamento
        FOREIGN KEY (sk_pagamento) REFERENCES dw.dim_pagamento(sk_pagamento),

    CONSTRAINT fk_status
        FOREIGN KEY (sk_status) REFERENCES dw.dim_status_pedido(sk_status)
);