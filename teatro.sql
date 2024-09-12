create schema teatro;
use teatro;

CREATE TABLE pecas_teatro (
    id_peca INT PRIMARY KEY AUTO_INCREMENT,
    nome_peca VARCHAR(100) NOT NULL,
    descricao TEXT,
    duracao INT,
    data_estreia DATE,
    diretor VARCHAR(100),
    elenco TEXT
);

ALTER TABLE pecas_teatro MODIFY COLUMN data_estreia DATETIME;


DELIMITER $$

CREATE FUNCTION calcular_media_duracao(id_peca INT)
RETURNS FLOAT
BEGIN
    DECLARE media_duracao FLOAT;

    SELECT AVG(duracao) INTO media_duracao
    FROM pecas_teatro
    WHERE id_peca = id_peca;

    RETURN media_duracao;
END $$

DELIMITER ;


delimiter $$
CREATE FUNCTION verificar_disponibilidade(data_hora DATETIME)
RETURNS BOOLEAN
BEGIN
    DECLARE disponivel BOOLEAN;

    IF EXISTS (
        SELECT 1
        FROM pecas_teatro
        WHERE data_estreia = data_hora
    ) THEN
     -- Não disponível
        SET disponivel = FALSE;
    ELSE
    -- Disponível
        SET disponivel = TRUE; 
    END IF;

    RETURN disponivel;
END$$

delimiter ;



DELIMITER $$

CREATE PROCEDURE agendar_peca(
    IN nome_peca VARCHAR(100),
    IN descricao TEXT,
    IN duracao INT,
    IN data_hora DATETIME,
    IN diretor VARCHAR(100),
    IN elenco TEXT
)
BEGIN
    DECLARE disponibilidade BOOLEAN;
    DECLARE media_duracao FLOAT;

    -- Verificar a disponibilidade usando a função verificar_disponibilidade
    SET disponibilidade = verificar_disponibilidade(data_hora);

    IF disponibilidade THEN
        -- Inserir a nova peça de teatro na tabela pecas_teatro
        INSERT INTO pecas_teatro (nome_peca, descricao, duracao, data_estreia, diretor, elenco)
        VALUES (nome_peca, descricao, duracao, data_hora, diretor, elenco);

        -- Calcular a média de duração usando a função calcular_media_duracao
        SET media_duracao = calcular_media_duracao(LAST_INSERT_ID());

        -- Imprimir informações sobre a peça agendada, incluindo a média de duração
        SELECT 
            nome_peca AS 'Nome da Peça',
            descricao AS 'Descrição',
            duracao AS 'Duração (minutos)',
            data_hora AS 'Data e Hora',
            diretor AS 'Diretor',
            elenco AS 'Elenco',
            media_duracao AS 'Média de Duração (minutos)'
        FROM pecas_teatro
        WHERE id_peca = LAST_INSERT_ID();
    ELSE
        SELECT 'A data e hora escolhidas já estão ocupadas. Por favor, escolha outro horário.' AS mensagem;
    END IF;
END $$

DELIMITER ;

INSERT INTO pecas_teatro (nome_peca, descricao, duracao, data_estreia, diretor, elenco)
VALUES 
('Romeu e Julieta',
 'Uma tragédia escrita por William Shakespeare sobre dois jovens amantes cuja morte acaba unindo suas famílias em conflito.', 
 120, 
 '2024-09-15 19:00:00',
 'João Silva', 
 'Maria Souza,Pedro Oliveira');
 
 INSERT INTO pecas_teatro (nome_peca, descricao, duracao, data_estreia, diretor, elenco)
VALUES 
('O Auto da Compadecida',
 'Uma peça de teatro brasileira escrita por Ariano Suassuna, que mistura elementos da cultura popular nordestina com temas universais.',
 110,
 '2024-09-17 18:00:00', 
 'Roberto Santos', 
 'José Almeida, Clara Nunes');
 
 INSERT INTO pecas_teatro (nome_peca, descricao, duracao, data_estreia, diretor, elenco)
VALUES 
('A Gaivota',
 'Uma peça de teatro escrita por Anton Tchekhov que explora as complexidades das relações humanas e as aspirações artísticas.',
 130,
 '2024-09-18 21:00:00',
 'Beatriz Ramos',
 'Lucas Ferreira, Juliana Martins');


CALL agendar_peca(
    'Macbeth',
    'Uma tragédia de William Shakespeare sobre a ascensão e queda de Macbeth.',
    140,
    '2024-09-15 19:00:00', -- Data e hora já ocupadas por 'Romeu e Julieta'
    'Carlos Silva',
    'João Pereira, Ana Costa'
);


CALL agendar_peca(
    'A Tempestade',
    'Uma peça de teatro de William Shakespeare sobre o mágico Próspero e sua busca por vingança.',
    130,
    '2024-09-19 20:00:00', -- Data e hora disponíveis
    'Mariana Oliveira',
    'Lucas Santos, Fernanda Lima'
);


