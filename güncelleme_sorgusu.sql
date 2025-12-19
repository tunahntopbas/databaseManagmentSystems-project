UPDATE Kurs
SET fiyat = 550.00
WHERE kurs_id = 1;

SELECT kurs_id, baslik, fiyat
FROM Kurs
ORDER BY kurs_id;
