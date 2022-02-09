# requite one

select COUNT(CASE WHEN (type_local = 'Appartement')
AND (date_mutation BETWEEN '2020-01-01' AND '2020-06-30') AND (nature_mutation = 'Vente') THEN 1 END) AS "Le nombre d'appartement vendue le premier semestre de 2020 est:"
FROM bien b
JOIN local l on b.code_type_local = l.code_type_local;

# requite two

select concat(cast(count(nature_mutation)as float)/ (select cast(count(nature_mutation) as float)
from bien b join local l on b.code_type_local = l.code_type_local where type_local = 'Appartement')* 100,'%') nbrs_apparts,
nbrs_pieces_principales
from bien b
join local l on b.code_type_local = l.code_type_local where type_local = 'Appartement'
group by nbrs_pieces_principales
order by nbrs_pieces_principales;

#requite three

select distinct code_dep, (select avg(valeur_fonc / surface_bati)) from bien b
join commune c on c.id_code_commune = b.id_code_commune group by code_dep
order by avg desc limit 10;

#requite four

SELECT cast(AVG(valeur_fonc / surface_bati) as decimal (10,2)) FROM Bien b
JOIN commune c on b.id_code_commune = c.id_code_commune JOIN local l on b.code_type_local = l.code_type_local
where code_dep in ('75', '77', '91', '78', '95', '93', '92', '94') AND type_local = 'Maison';

#requite five

SELECT valeur_fonc, code_dep, surface_bati
from bien b
join commune c on b.id_code_commune = c.id_code_commune join local l on b.code_type_local = l.code_type_local
where type_local = 'Appartement' and valeur_fonc != 0
order by valeur_fonc desc limit 10;

#requite six

premier_trim view:
CREATE OR REPLACE VIEW premier_trim
AS
SELECT count(date_mutation) AS premier_trim FROM bien
WHERE (date_mutation between '2020-01-01' AND ‘2020-03-31’)

second_trim view:
CREATE OR REPLACE VIEW second_trim
AS
SELECT count(date_mutation) AS second_trim FROM bien
WHERE (date_mutation between '2020-04-01' AND '2020-06-30')

select concat(round((cast(second_trim as numeric) - cast(premier_trim as numeric)) / premier_trim*100,2),'%') as evo_prix
from premier_trim , second_trim;

#requite seven

Premier_view :
premier_trim view: SELECT count(date_mutation) AS premier_trim, nom_commune
FROM bien b
JOIN commune c ON b.id_code_commune = c.id_code_commune
WHERE b.date_mutation >= '2020-01-01'::date AND b.date_mutation <= '2020-03-31'::date GROUP BY c.nom_commune;
second_view:
second_trim view: SELECT count(date_mutation) AS second_trim, c.nom_commune
FROM bien b
JOIN commune c ON b.id_code_commune = c.id_code_commune
WHERE b.date_mutation >= '2020-04-01'::date AND b.date_mutation <= '2020-06-30'::date GROUP BY c.nom_commune;
premier_trim view: SELECT count(date_mutation) AS premier_trim, nom_commune
FROM bien b
JOIN commune c ON b.id_code_commune = c.id_code_commune
WHERE b.date_mutation >= '2020-01-01'::date AND b.date_mutation <= '2020-03-31'::date GROUP BY c.nom_commune;

#requite eight

2piece view:
View 2pieces: SELECT avg(valeur_fonc / surface_bati) AS prix_m2_2pieces FROM bien b
JOIN local l ON b.code_type_local = l.code_type_local
WHERE nbrs_pieces_principales = 2 AND type_local = 'Appartement';

3piece views:
View 3pieces: SELECT avg(valeur_fonc / surface_bati) AS prix_m2_3pieces FROM bien b
JOIN local l ON b.code_type_local = l.code_type_local
WHERE nbrs_pieces_principales = 3 AND type_local = 'Appartement';
select concat(sum(cast((prix_m2_3pieces - prix_m2_2pieces)/prix_m2_2pieces as float)*100),'%') from prix_2pieces ,prix_3pieces;

#requite nine

moyenne_val_fonc view:
create view moyenne_val_fonc as
SELECT nom_commune commune, code_dep,
round(AVG(valeur_fonc)) "valeur fonciere",
row_number() over( partition by code_Dep order by avg(valeur_fonc) desc) "id"
from bien b
join commune c on b.id_code_commune = c.id_code_commune where code_dep in ('6', '13', '33', '59', '69')
group by nom_commune, code_dep
select *
from moyenne_val_fonc where id <= 3;
