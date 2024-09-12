create schema halloween;
use halloween;

create table tabela_usuario(
id integer primary key auto_increment,
nome text,
email text,
idade integer
);

DELIMITER $$
create procedure InsereUsuariosAleatorios()
begin

declare i int default 0;

-- Loop para inserir 10.000 registros 
while i <= 10000 do
	-- gere dados aleatórios para os campos
    set @nome := concat('usuario',i);
    set @email := concat('usuario',i, '@exemplo.com');
    set @idade := floor(rand() * 80) + 18; -- gera uma idade entre 18 e 97 anos
    
    -- Insira o novo registro na tabela usuários
    insert into tabela_usuario(nome, email, idade) values (@nome, @email, @idade);
    -- incrementa contador
    set i = i + 1;
    END WHILE;
    END $$
    
    -- Restaure o delimitador padrão

DELIMITER ; 