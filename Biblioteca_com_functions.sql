create schema biblioteca;
use biblioteca;

create table autor (
id integer primary key auto_increment,
nome varchar (20),
sobrenome varchar (50),
biografia varchar (500)
);

create table autor_livro (
id_autor integer,
id_livro integer,
foreign key (id_autor) references autor(id),
foreign key (id_livro) references livro(id)
);

create table livro(
id integer primary key auto_increment,
titulo varchar (50),
isbn varchar (100),
ano_publicacao date,
exemplares integer
);

create table usuario(
id integer primary key auto_increment,
nome varchar (50),
situacao varchar (7),
dt_cadastro date
);

create table emprestimo(
id integer primary key auto_increment,
id_livro integer,
id_usuario integer,
dt_reserva date,
dt_devolucao date,
situacao varchar (15),
foreign key (id_livro) references livro (id),
foreign key (id_usuario) references usuario (id)
);

create table devolucoes(
id integer primary key auto_increment,
id_livro integer,
id_usuario integer,
data_devolucao date,
data_devolucao_esperada date,
foreign key (id_livro) references livro (id),
foreign key (id_usuario) references usuario (id)
);

create table multas(
id integer primary key auto_increment,
id_usuario integer,
valor_multa decimal (10, 2),
data_multa date,
foreign key (id_usuario) references usuario (id)
);

create table mensagens(
id integer primary key auto_increment,
destinatario varchar (255) not null,
assunto varchar (255) not null,
corpo text, 
data_envio datetime default current_timestamp
);


create table livros_atualizado(
id integer primary key auto_increment,
id_livro integer not null,
titulo varchar (255) not null,
data_atualizacao datetime default current_timestamp
);

create table autor_livro_att(
id_autor integer,
id_livros_atualizado integer,
foreign key (id_autor) references autor(id),
foreign key (id_livros_atualizado) references livros_atualizado(id)
);

create table livros_excluidos(
id integer primary key auto_increment,
id_livro integer not null,
titulo varchar (255) not null,
data_exclusao datetime default current_timestamp
);

create table autor_livro_excluido(
id_autor integer,
id_livros_excluidos integer,
foreign key (id_autor) references autor(id),
foreign key (id_livros_excluidos) references livros_excluidos(id)
);

delimiter 
create trigger trigger_gerar_multa after insert on devolucoes for each row
begin
declare atraso int;
declare valor_multa decimal(10, 2);

	set atraso = datediff(new.data_devolucao_esperada, new.data_devolucao); 
	if atraso > 0 then
	set valor_multa = atraso * 2.00;
    insert into multas (id_usuario, valor_multa, data_multa)
values (new.id_usuario, valor_multa, now());
end if;
end;
delimiter ;

delimiter 
create trigger trigger_verificar_atrasos before insert on devolucoes for each row
begin
declare atraso int;


	set atraso = datediff(new.data_devolucao_esperada, new.data_devolucao); 
	if atraso > 0 then
	insert into mensagens (destinatário, assunto, corpo)
	values ('Bibliotecário', 'Alerta de atraso', concat('O livro com id', new.id_livro, 'não foi devolvido na data de devolução esperada'));
end if;
end;
delimiter ;

delimiter 
create trigger trigger_atualizar_status_emprestado after insert on emprestimo for each row
begin
update livros
set status_livro = 'Emprestado' 
where id = new.id_livro;
end;
delimiter ;

delimiter 
create trigger trigger_atualizar_tota_exemplares after insert on livro for each row
begin
update livros
set exemplares = exemplares + 1
where id = new.id;
end;
delimiter ;

delimiter 
create trigger trigger_registrar_atualizacao_livro after update on livro for each row
begin
 
insert into livros_atualizados (id_livro, titulo, data_atualização)

values( old.id, old.titulo, now());

end;
delimiter ;

delimiter 
create trigger trigger_registrar_exclusao_livro after delete on livro for each row
begin
 
insert into livros_excluidos (id, titulo, data_exclusao)

values( old.id, old.titulo, now());

end;
delimiter ;

select avg(valor_multa) as media_valor_multa from multas;

select max(valor_multa) as maximo_valor_multa from multas;

select min(valor_multa) as minimo_valor_multa from multas;

select count(id) as total_autores from autor;

select count(id) as total_livros from livro;

select count(id) as total_usuarios from usuario;

select count(id) as total_livros_excluidos from  livros_excluidos;

select count(id) as total_livros_atualizado from  livros_atualizados;

select sum(exemplares) as exeplares_totais from livro;

select sum(valor_multa) as valor_total_multa from multas;