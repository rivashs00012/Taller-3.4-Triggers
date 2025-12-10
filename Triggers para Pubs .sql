use pubs;
go
--==========================================================================
-- 1. crear tabla de auditoría
create table auditoria_titles
(
    title_id varchar(20),
    fecha_eliminacion date
);
go

-- 2. crear trigger
drop trigger if exists trg_delete_titles;
go

create trigger trg_delete_titles
on titles
after delete
as
begin
    insert into auditoria_titles (title_id, fecha_eliminacion)
    select 
        d.title_id,
        cast(getdate() as date)
    from deleted d;
end;
go


-- borrar primero en las tablas hijas (para evitar error de FK)

-- 1. borrar en sales
delete from sales where title_id = 'BU1032';
go

-- 2. borrar en titleauthor
delete from titleauthor where title_id = 'BU1032';
go

-- 3. borrar en roysched
delete from roysched where title_id = 'BU1032';
go


-- 4. ahora sí borrar en titles (aquí se activa el trigger)
delete from titles where title_id = 'BU1032';
go


-- 5. verificar resultados
select * from titles;
select * from auditoria_titles;
go






--==========================================================================
-- 2
use pubs;
go

-- 1. crear tabla de auditoría para autores
create table auditoria_authors
(
    au_id varchar(20),
    fecha_eliminacion date
);
go


-- 2. eliminar trigger si existe
drop trigger if exists trg_delete_authors;
go


-- 3. crear trigger
create trigger trg_delete_authors
on authors
after delete
as
begin
    insert into auditoria_authors (au_id, fecha_eliminacion)
    select 
        d.au_id,
        cast(getdate() as date)
    from deleted d;
end;
go


-- 4. borrar primero en tabla hija (titleauthor)
delete from titleauthor
where au_id = '172-32-1176';
go


-- 5. ahora borrar en authors (se activa el trigger)
delete from authors
where au_id = '172-32-1176';
go


-- 6. verificar
select * from authors;
select * from auditoria_authors;
go





--==========================================================================
--3
use pubs;
go

-- 1. crear tabla de auditoría de actualización
create table auditoria_update_titles
(
    title_id varchar(20),
    precio_anterior money,
    precio_nuevo money,
    fecha_cambio date
);
go


-- 2. eliminar trigger si existe
drop trigger if exists trg_update_titles;
go


-- 3. crear trigger de update
create trigger trg_update_titles
on titles
after update
as
begin
    insert into auditoria_update_titles
    select 
        d.title_id,
        d.price,
        i.price,
        cast(getdate() as date)
    from deleted d
    inner join inserted i
        on d.title_id = i.title_id;
end;
go


-- 4. prueba (modificar precio)
update titles
set price = price + 5
where title_id = 'BU1111';
go


-- 5. verificar
select * from titles;
select * from auditoria_update_titles;
go





--==========================================================================
--4
use pubs;
go

-- 1. crear tabla de auditoría para inserciones
create table auditoria_insert_titles
(
    title_id varchar(20),
    fecha_insercion date
);
go


-- 2. eliminar trigger si existe
drop trigger if exists trg_insert_titles;
go


-- 3. crear trigger insert
create trigger trg_insert_titles
on titles
after insert
as
begin
    insert into auditoria_insert_titles (title_id, fecha_insercion)
    select 
        i.title_id,
        cast(getdate() as date)
    from inserted i;
end;
go


-- 4. prueba: insertar un nuevo título
insert into titles 
(title_id, title, type, pub_id, price, advance, royalty, ytd_sales, notes, pubdate)
values
('ZZ9999', 'libro prueba trigger', 'business', '1389', 20, 0, 10, 0, 'prueba insert', getdate());
go


-- 5. verificar
select * from titles where title_id = 'ZZ9999';
select * from auditoria_insert_titles;
go








--==========================================================================
--5


use pubs;
go

-- 1. crear tabla de auditoría para borrados en sales
create table auditoria_sales
(
    stor_id char(4),
    ord_num varchar(20),
    title_id varchar(20),
    fecha_eliminacion date
);
go


-- 2. eliminar trigger si existe
drop trigger if exists trg_delete_sales;
go


-- 3. crear trigger delete en sales
create trigger trg_delete_sales
on sales
after delete
as
begin
    insert into auditoria_sales (stor_id, ord_num, title_id, fecha_eliminacion)
    select 
        d.stor_id,
        d.ord_num,
        d.title_id,
        cast(getdate() as date)
    from deleted d;
end;
go


-- 4. prueba: eliminar una venta
delete from sales
where ord_num = '722a';
go


-- 5. verificar
select * from sales;
select * from auditoria_sales;
go

--para verificar id reales 
select * from sales;

--==========================================================================
