USE universitatea
GO

-- query 8
SELECT DISTINCT studenti.Id_Student, studenti.Nume_Student FROM studenti
INNER JOIN studenti_reusita
ON studenti.Id_Student=studenti_reusita.Id_Student
	WHERE YEAR(studenti_reusita.Data_Evaluare) = 2018 AND studenti_reusita.Tip_Evaluare='Examen';
-- query 9
SELECT DISTINCT studenti.Nume_Student, studenti.Adresa_Postala_Student, studenti_reusita.Id_Disciplina FROM studenti
INNER JOIN studenti_reusita
ON studenti.Id_Student=studenti_reusita.Id_Student
	WHERE studenti_reusita.Nota>8 AND YEAR(studenti_reusita.Data_Evaluare) = 2018;
-- query 10
SELECT DISTINCT studenti.Nume_Student, studenti.Prenume_Student FROM studenti
INNER JOIN studenti_reusita
ON studenti.Id_Student=studenti_reusita.Id_Student
	WHERE studenti_reusita.Nota<8 AND studenti_reusita.Nota>4 AND YEAR(studenti_reusita.Data_Evaluare) = 2018 AND studenti_reusita.Tip_Evaluare='Examen'; 

-- query 18
SELECT profesori.Nume_Profesor, profesori.Prenume_Profesor FROM profesori
	WHERE profesori.Id_Profesor = ANY
	(SELECT DISTINCT studenti_reusita.Id_Profesor FROM discipline 
	INNER JOIN studenti_reusita
	ON discipline.Id_Disciplina=studenti_reusita.Id_Disciplina
		WHERE discipline.Nr_ore_plan_disciplina < 60);
-- query 19
SELECT DISTINCT profesori.Nume_Profesor, profesori.Prenume_Profesor FROM studenti
INNER JOIN studenti_reusita ON studenti.Id_Student = studenti_reusita.Id_Student
INNER JOIN profesori ON studenti_reusita.Id_Profesor = profesori.Id_Profesor
	WHERE studenti.Nume_Student = 'Cosovanu' AND studenti_reusita.Nota<5;
-- query 20
SELECT COUNT(stud.Id_Student) FROM 
	(SELECT DISTINCT studenti_reusita.Id_Student FROM studenti_reusita
		WHERE studenti_reusita.Nota>5 
		AND YEAR(studenti_reusita.Data_Evaluare)=2017 
		AND studenti_reusita.Tip_Evaluare = 'Testul 2') AS stud;
	
-- query 21
SELECT studenti.Nume_Student, studenti.Prenume_Student, stud.Nr_note FROM studenti
INNER JOIN 
	(SELECT studenti_reusita.Id_Student, COUNT(studenti_reusita.Nota) AS Nr_note FROM studenti_reusita
	GROUP BY studenti_reusita.Id_Student) AS stud 
	ON stud.Id_Student = studenti.Id_Student;
-- query 22
SELECT profesori.Nume_Profesor, profesori.Prenume_Profesor, COUNT(prof.Id_Disciplina) AS Nr_discipline FROM profesori
INNER JOIN (SELECT DISTINCT studenti_reusita.Id_Profesor, discipline.Id_Disciplina FROM studenti_reusita
INNER JOIN discipline ON discipline.Id_Disciplina = studenti_reusita.Id_Disciplina) AS prof ON prof.Id_Profesor = profesori.Id_Profesor
GROUP BY profesori.Nume_Profesor, profesori.Prenume_Profesor;
-- query 25
SELECT list.Id_Grupa FROM 
(SELECT DISTINCT grupe.Id_Grupa, studenti.Id_Student FROM studenti
INNER JOIN studenti_reusita ON studenti.Id_Student = studenti_reusita.Id_Student
INNER JOIN grupe ON grupe.Id_Grupa = studenti_reusita.Id_Grupa) AS list
GROUP BY list.Id_Grupa
HAVING COUNT(list.Id_Student)>24
