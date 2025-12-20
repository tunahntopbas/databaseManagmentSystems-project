CREATE OR REPLACE FUNCTION ogrenci_quiz_dogru_sayisi(
    p_ogrenci_id INTEGER,
    p_quiz_id    INTEGER
)
RETURNS INTEGER
LANGUAGE plpgsql
AS $$
DECLARE
    v_dogru_sayisi INTEGER;
BEGIN
    SELECT COUNT(*)
    INTO v_dogru_sayisi
    FROM Ogrenci_Cevap oc
    JOIN Soru s     ON s.soru_id = oc.soru_id
    JOIN Secenek se ON se.secenek_id = oc.secenek_id
    WHERE oc.ogrenci_id = p_ogrenci_id
      AND s.quiz_id     = p_quiz_id
      AND se.dogru_mu   = TRUE;

    RETURN COALESCE(v_dogru_sayisi, 0);
END;
$$;


CREATE OR REPLACE FUNCTION kurs_puan_guncelle(
    p_kurs_id INTEGER
)
RETURNS VOID
LANGUAGE plpgsql
AS $$
DECLARE
    v_ortalama DECIMAL(3,2);
    v_sayi     INTEGER;
BEGIN
    SELECT AVG(puan)::DECIMAL(3,2), COUNT(*)
    INTO v_ortalama, v_sayi
    FROM Yorum
    WHERE kurs_id = p_kurs_id;

    UPDATE Kurs
    SET ortalama_puan = CASE WHEN v_sayi = 0 THEN NULL ELSE v_ortalama END,
        yorum_sayisi  = v_sayi
    WHERE kurs_id = p_kurs_id;
END;
$$;

CREATE OR REPLACE FUNCTION kayit_durum_guncelle(p_kayit_id INT)
RETURNS void AS $$
DECLARE
    toplam_odeme NUMERIC;
    kurs_fiyat NUMERIC;
    mevcut_durum TEXT;
BEGIN
    SELECT durum INTO mevcut_durum
    FROM Kayit
    WHERE kayit_id = p_kayit_id;


    IF mevcut_durum = 'iptal' THEN
        RETURN;
    END IF;

    SELECT COALESCE(SUM(tutar), 0) INTO toplam_odeme
    FROM Odeme
    WHERE kayit_id = p_kayit_id;

    SELECT k.fiyat INTO kurs_fiyat
    FROM Kurs k
    JOIN Kayit ka ON ka.kurs_id = k.kurs_id
    WHERE ka.kayit_id = p_kayit_id;

    IF toplam_odeme >= kurs_fiyat THEN
        UPDATE Kayit SET durum = 'tamamlandi'
        WHERE kayit_id = p_kayit_id;
    ELSE
        UPDATE Kayit SET durum = 'aktif'
        WHERE kayit_id = p_kayit_id;
    END IF;
END;
$$ LANGUAGE plpgsql;



CREATE OR REPLACE FUNCTION kullanici_kayit_temizle_ve_rol_kontrol()
RETURNS VOID
AS
$$
BEGIN
    
    UPDATE Kullanici
    SET email = LOWER(TRIM(email)),
        ad    = TRIM(ad),
        soyad = TRIM(soyad);

    
    IF EXISTS (
        SELECT 1
        FROM Kullanici
        WHERE rol IS NULL
           OR rol NOT IN ('ogrenci', 'egitmen', 'admin')
    ) THEN
        RAISE EXCEPTION 'Kullanici tablosunda gecersiz veya bos rol degeri var.';
    END IF;
END;
$$
LANGUAGE plpgsql;
