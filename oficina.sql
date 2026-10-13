-- Cadastro de Clientes
CREATE TABLE clientes (
    id_cliente INTEGER PRIMARY KEY AUTOINCREMENT,
    nome TEXT NOT NULL,
    cpf TEXT UNIQUE NOT NULL,
    telefone TEXT NOT NULL,
    email TEXT,
    endereco TEXT,
    data_cadastro TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Cadastro de Veículos
CREATE TABLE veiculos (
    id_veiculo INTEGER PRIMARY KEY AUTOINCREMENT,
    id_cliente INTEGER NOT NULL,
    placa TEXT UNIQUE NOT NULL,
    marca TEXT NOT NULL,
    modelo TEXT NOT NULL,
    ano INTEGER,
    cor TEXT,
    FOREIGN KEY (id_cliente) REFERENCES clientes(id_cliente) ON DELETE CASCADE
);

-- Mecânicos e Serviços
CREATE TABLE mecanicos (
    id_mecanico INTEGER PRIMARY KEY AUTOINCREMENT,
    nome TEXT NOT NULL,
    especialidade TEXT
);

CREATE TABLE servicos (
    id_servico INTEGER PRIMARY KEY AUTOINCREMENT,
    descricao TEXT NOT NULL,
    preco_base REAL NOT NULL
);

-- Ordem de Serviço (OS)
CREATE TABLE ordens_servico (
    id_os INTEGER PRIMARY KEY AUTOINCREMENT,
    id_veiculo INTEGER NOT NULL,
    id_mecanico INTEGER,
    data_abertura TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    data_aprovacao TIMESTAMP NULL,
    data_conclusao TIMESTAMP NULL,
    status TEXT CHECK(status IN (
        'Orçamento Pendente', 
        'Aguardando Aprovação', 
        'Aprovado', 
        'Em Andamento', 
        'Concluído', 
        'Cancelado'
    )) DEFAULT 'Orçamento Pendente',
    observacoes_mecanico TEXT,
    valor_total REAL DEFAULT 0.00,
    FOREIGN KEY (id_veiculo) REFERENCES veiculos(id_veiculo),
    FOREIGN KEY (id_mecanico) REFERENCES mecanicos(id_mecanico)
);

-- Itens da OS (Serviços/Peças aplicados)
CREATE TABLE itens_os (
    id_item INTEGER PRIMARY KEY AUTOINCREMENT,
    id_os INTEGER NOT NULL,
    id_servico INTEGER NOT NULL,
    quantidade INTEGER DEFAULT 1,
    valor_unitario REAL NOT NULL,
    subtotal REAL GENERATED ALWAYS AS (quantidade * valor_unitario) STORED,
    FOREIGN KEY (id_os) REFERENCES ordens_servico(id_os) ON DELETE CASCADE,
    FOREIGN KEY (id_servico) REFERENCES servicos(id_servico)
);

-- Gatilho para somar o total da OS automaticamente
CREATE TRIGGER trg_soma_total_os
AFTER INSERT ON itens_os
FOR EACH ROW
BEGIN
    UPDATE ordens_servico
    SET valor_total = valor_total + NEW.subtotal
    WHERE id_os = NEW.id_os;
END;

-- Inserção de Dados para Teste
INSERT INTO clientes (nome, cpf, telefone, email) VALUES 
('Carlos Silva', '111.222.333-44', '(81) 98765-4321', 'carlos@email.com'),
('Ana Paula', '555.666.777-88', '(81) 99999-1111', 'ana@email.com');

INSERT INTO veiculos (id_cliente, placa, marca, modelo, ano) VALUES 
(1, 'ABC-1234', 'Chevrolet', 'Onix', 2020),
(2, 'XYZ-9876', 'Honda', 'Civic', 2018);

INSERT INTO mecanicos (nome, especialidade) VALUES ('Roberto', 'Suspensão e Freios');
INSERT INTO servicos (descricao, preco_base) VALUES ('Troca de Óleo', 150.00), ('Pastilha de Freio', 250.00);

-- Criando OS de teste
INSERT INTO ordens_servico (id_veiculo, id_mecanico, status) VALUES 
(1, 1, 'Em Andamento'),
(2, 1, 'Orçamento Pendente');

INSERT INTO itens_os (id_os, id_servico, quantidade, valor_unitario) VALUES 
(1, 2, 1, 250.00),
(1, 1, 1, 150.00),
(2, 1, 1, 150.00);