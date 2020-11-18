use universitatea;

-- task 1
update profesori
set Adresa_Postala_Profesor = 'mun.Chisinau'
where Adresa_Postala_Profesor is null;

-- task 2
-- Note: Cod_Grupa already does not accept null values!
alter table grupe
add constraint unique_gorup_code
UNIQUE(Cod_Grupa);

-- task 3 a
alter table grupe
add 
Sef_grupa INT,
Prof_Indrumator INT;

declare @group_number INT = 1;
declare @group_id INT;
declare @idStudent_max_mark table
(
	[Id_Student_sef] [int],
	[Id_Grupa] [int]
);

while @group_number <= (
	select COUNT(Id_Grupa) 
	from (select distinct grupe.Id_Grupa from grupe 
	inner join studenti_reusita on studenti_reusita.Id_Grupa=grupe.Id_Grupa) as g
	)
begin

	insert into @idStudent_max_mark values
	(
		(
			select top 1 Id_Student from
				(select Id_Student, Id_Grupa, AVG(Nota) as Nota from
					(select studenti_reusita.Id_Student, studenti_reusita.Id_Grupa, studenti_reusita.Nota from studenti
					inner join studenti_reusita on studenti.Id_Student=studenti_reusita.Id_Student
					inner join grupe on studenti_reusita.Id_Grupa=grupe.Id_Grupa
					where Tip_Evaluare='Reusita curenta' and grupe.Id_Grupa=@group_number) as Notele
				group by Notele.Id_Student, Notele.Id_Grupa) as Studentii
			where Nota = (
			select MAX(Nota) from
				(select AVG(Nota) as Nota from
					(select studenti_reusita.Id_Student, studenti_reusita.Id_Grupa, studenti_reusita.Nota from studenti
					inner join studenti_reusita on studenti.Id_Student=studenti_reusita.Id_Student
					inner join grupe on studenti_reusita.Id_Grupa=grupe.Id_Grupa
					where Tip_Evaluare='Reusita curenta' and grupe.Id_Grupa=@group_number) as Notele
				group by Notele.Id_Student, Notele.Id_Grupa) as n
			)
		)
	,
		(select Id_Grupa from
			(select Id_Grupa, ROW_NUMBER() over (order by Id_Grupa) as rn from 
				(select distinct grupe.Id_Grupa from grupe
				inner join studenti_reusita on studenti_reusita.Id_Grupa=grupe.Id_Grupa) as g
			) as g2
		where g2.rn = @group_number)
	); 
	set @group_number = @group_number + 1;
end;

select * from @idStudent_max_mark;
/* Returns:
Id_Student_sef	Id_Grupa
104			1
152			2
149			3
*/

set @group_number=1;
while @group_number <= (
	select COUNT(Id_Grupa) 
	from (select distinct grupe.Id_Grupa from grupe 
	inner join studenti_reusita on studenti_reusita.Id_Grupa=grupe.Id_Grupa) as g
	)
begin

	set @group_id = (select Id_Grupa from
			(select Id_Grupa, ROW_NUMBER() over (order by Id_Grupa) as rn from 
				(select distinct grupe.Id_Grupa from grupe
				inner join studenti_reusita on studenti_reusita.Id_Grupa=grupe.Id_Grupa) as g
			) as g2
		where g2.rn = @group_number);

	update grupe
	set Sef_grupa = (select Id_Student_sef from @idStudent_max_mark where Id_Grupa=@group_id)
	where Id_Grupa = @group_id;
	set @group_number = @group_number + 1;
end;

-- task 3 b

set @group_number=1;
while @group_number <= (
	select COUNT(Id_Grupa) 
	from (select distinct grupe.Id_Grupa from grupe 
	inner join studenti_reusita on studenti_reusita.Id_Grupa=grupe.Id_Grupa) as g
	)
begin

	set @group_id = (select Id_Grupa from
			(select Id_Grupa, ROW_NUMBER() over (order by Id_Grupa) as rn from 
				(select distinct grupe.Id_Grupa from grupe
				inner join studenti_reusita on studenti_reusita.Id_Grupa=grupe.Id_Grupa) as g
			) as g2
		where g2.rn = @group_number);

	update grupe
	set Prof_Indrumator = (select top 1 Id_Profesor from
		(select top 1 Id_Profesor, COUNT(Id_Disciplina) as disciplines from
			(select distinct profesori.Id_Profesor, studenti_reusita.Id_Disciplina from profesori
			inner join studenti_reusita on profesori.Id_Profesor=studenti_reusita.Id_Profesor
			where Id_Grupa=@group_id) as p
		group by Id_Profesor
		order by Id_Profesor asc, disciplines desc) as p1)
	where grupe.Id_Grupa = @group_id;

	set @group_number = @group_number + 1;
end;

select * from grupe;

-- task 4
update studenti_reusita
set studenti_reusita.Nota = s2.Nota+1
from
		(select Id_Student from grupe
		inner join studenti on studenti.Id_Student=grupe.Sef_grupa) as s
	inner join studenti_reusita as s2 on s2.Id_Student=s.Id_Student
where Nota<10 
	AND 
	(Tip_Evaluare='Testul 1' OR Tip_Evaluare='Testul 2' OR Tip_Evaluare='Examen')
	AND 
	s.Id_Student = s2.Id_Student;

-- task 5
create table profesori_new(
	Id_Profesor int primary key,
	Nume_Profesor varchar(20),
	Prenume_Profesor varchar(20),
	Localitate varchar(50) default 'mun.Chisinau',
	Adresa_1 varchar(30),
	Adresa_2 varchar(30)
);
-- When the primary key constraint is created, 
-- a unique clustered index on the column is automatically created.

insert into profesori_new(Id_Profesor, Nume_Profesor, Prenume_Profesor)
select Id_Profesor, Nume_Profesor, Prenume_Profesor from profesori;

update profesori_new
set Localitate = a.addr
from (select Id_Profesor, COALESCE(NULLIF(SUBSTRING(Adresa_Postala_Profesor, 0, CHARINDEX(',', Adresa_Postala_Profesor)), ''), Adresa_Postala_Profesor) as addr
from profesori) as a
where profesori_new.Id_Profesor=a.Id_Profesor and (addr like '%mun.%' or addr like '%r.%');

update profesori_new
set Localitate = CONCAT(Localitate, a.addr)
from (select Id_Profesor, NULLIF(SUBSTRING(Adresa_Postala_Profesor, CHARINDEX(',', Adresa_Postala_Profesor),  CHARINDEX(',', Adresa_Postala_Profesor,CHARINDEX(',', Adresa_Postala_Profesor)+1)-CHARINDEX(',', Adresa_Postala_Profesor)), '') as addr
from profesori) as a
where profesori_new.Id_Profesor=a.Id_Profesor and (addr like '%s.%' or addr like '%or.%');

update profesori_new
set Adresa_1 = a.addr
from (select Id_Profesor, NULLIF(SUBSTRING(Adresa_Postala_Profesor, CHARINDEX(',', Adresa_Postala_Profesor)+1,  CHARINDEX(',', Adresa_Postala_Profesor,CHARINDEX(',', Adresa_Postala_Profesor)+1)-CHARINDEX(',', Adresa_Postala_Profesor)), '') as addr
from profesori) as a
where profesori_new.Id_Profesor=a.Id_Profesor and (addr like '%bd.%' or addr like '%str.%');

update profesori_new
set Adresa_2 = a.addr
from (select Id_Profesor, NULLIF(SUBSTRING(Adresa_Postala_Profesor, CHARINDEX(',', Adresa_Postala_Profesor,CHARINDEX(',', Adresa_Postala_Profesor)+1)+1,  CHARINDEX(',', Adresa_Postala_Profesor,CHARINDEX(',', Adresa_Postala_Profesor,CHARINDEX(',', Adresa_Postala_Profesor))+1)+1), '') as addr
from profesori) as a
where addr like '[0-9/ ]%' and not addr like '%[a-z]%'
	and a.Id_Profesor=profesori_new.Id_Profesor;

-- task 6
create table orarul(
	Id_Disciplina INT,
	Id_Profesor INT,
	Ora varchar(10),
	Auditoriu int
);

insert into orarul
values(107, 101,'08:00',202),
(108,101,'11:30',501),
(109,117,'13:00',501);

-- task 7

insert into orarul
values
(
	(select Id_Disciplina
	from discipline
	where Disciplina='Structuri de date si algoritmi'),
	(select Id_Profesor
	from profesori
	where Nume_Profesor='Bivol' and Prenume_Profesor='Ion'),
	'8:00',
	null
);

insert into orarul
values
(
	(select Id_Disciplina
	from discipline
	where Disciplina='Programe aplicative'),
	(select Id_Profesor
	from profesori
	where Nume_Profesor='Mircea' and Prenume_Profesor='Sorin'),
	'11:30',
	null
);

insert into orarul
values
(
	(select Id_Disciplina
	from discipline
	where Disciplina='Baze de date'),
	(select Id_Profesor
	from profesori
	where Nume_Profesor='Micu' and Prenume_Profesor='Elena'),
	'13:00',
	null
);