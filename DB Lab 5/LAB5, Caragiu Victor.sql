print('task 1');
declare @N1 INT, @N2 INT, @N3 INT;
declare @mai_mare INT;

set @N1 = 60 * RAND();
set @N2 = 60 * RAND();
set @N3 = 60 * RAND();
if (@N1 < @N2 and @N3 < @N2)
	set @mai_mare = @N2;	
if (@N2 < @N1 and @N3 < @N1)
	set @mai_mare = @N1;
else
	set @mai_mare = @N3;
PRINT @N1;
PRINT @N2;
PRINT @N3;
PRINT 'Mai mare = ' + CAST(@mai_mare as VARCHAR(2));


print('task 2');
use universitatea;
declare @disciplina VARCHAR(50) = 'Baze de date';
declare @mark1 INT = 6;
declare @mark2 INT = 8;

select distinct top 10 Nume_Student, Prenume_Student from
	(select studenti.Nume_Student, studenti.Prenume_Student, IIF(Nota = @mark1 or Nota = @mark2, NULL, Nota) as Nota from studenti
	inner join studenti_reusita on studenti.Id_Student=studenti_reusita.Id_Student
	inner join 
		(select Id_Disciplina from discipline
		where Disciplina=@disciplina) 
	as dis 
	on dis.Id_Disciplina=studenti_reusita.Id_Disciplina)
as results
where Nota is not NULL
order by Nume_Student;


print('task 3');
set @N1 = 60 * RAND();
set @N2 = 60 * RAND();
set @N3 = 60 * RAND();
set @mai_mare = case
	when (@N2 < @N1 and @N3 < @N1) then @N1
	when (@N1 < @N2 and @N3 < @N2) then @N1
	else @N3
end
PRINT @N1;
PRINT @N2;
PRINT @N3;
PRINT 'Mai mare = ' + CAST(@mai_mare as VARCHAR(2));


print('task 4.1');
set @N1 = 60 * RAND();
set @N2 = 60 * RAND();
set @N3 = 60 * RAND();
declare @max decimal(4,2);

begin try
	if (@N1 < @N2 and @N3 < @N2)
		set @max = @N2;	
	if (@N2 < @N1 and @N3 < @N1)
		set @max = @N1;
	else
		set @max = @N3;
	PRINT @N1;
	PRINT @N2;
	PRINT @N3;
	PRINT 'Mai mare = ' + CAST(@max as VARCHAR(2));
end try
begin catch
	print('Arithmetic overflow error converting numeric to data type varchar.')
	SELECT ERROR_MESSAGE() as ERROR
end catch;


print('task 4.2');
declare @amount INT = NULL;

begin try
	select distinct top (@amount) Nume_Student, Prenume_Student from
		(select studenti.Nume_Student, studenti.Prenume_Student, IIF(Nota = @mark1 or Nota = @mark2, NULL, Nota) as Nota from studenti
		inner join studenti_reusita on studenti.Id_Student=studenti_reusita.Id_Student
		inner join 
			(select Id_Disciplina from discipline
			where Disciplina=@disciplina) 
		as dis 
		on dis.Id_Disciplina=studenti_reusita.Id_Disciplina)
	as results
	where Nota is not NULL
	order by Nume_Student;
end try
begin catch
	print('A TOP or FETCH clause contains an invalid value.')
	SELECT ERROR_MESSAGE() as ERROR
end catch;

