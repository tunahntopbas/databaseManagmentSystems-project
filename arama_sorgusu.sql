SELECT 
    k.kullanici_id,
    k.ad,
    k.soyad,
    ku.kurs_id,
    ku.baslik AS kurs_baslik,
    ka.durum AS kayit_durumu,
    ku.ortalama_puan,
    ku.yorum_sayisi
FROM Kayit ka
JOIN Ogrenci o   ON o.kullanici_id = ka.ogrenci_id
JOIN Kullanici k ON k.kullanici_id = o.kullanici_id
JOIN Kurs ku     ON ku.kurs_id = ka.kurs_id
ORDER BY k.kullanici_id, ku.kurs_id;
