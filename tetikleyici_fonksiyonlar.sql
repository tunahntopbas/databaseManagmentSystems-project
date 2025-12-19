CREATE OR REPLACE FUNCTION kullanici_kayit_kontrol()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    NEW.email := LOWER(TRIM(NEW.email));
    NEW.ad    := TRIM(NEW.ad);
    NEW.soyad := TRIM(NEW.soyad);

    IF NEW.rol NOT IN ('ogrenci', 'egitmen', 'admin') THEN
        RAISE EXCEPTION 'Gecersiz rol: %', NEW.rol;
    END IF;

    RETURN NEW;
END;
$$;

CREATE OR REPLACE FUNCTION yorum_kayit_kontrol()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
DECLARE
    v_sayi INTEGER;
BEGIN
    SELECT COUNT(*)
    INTO v_sayi
    FROM Kayit
    WHERE ogrenci_id = NEW.ogrenci_id
      AND kurs_id    = NEW.kurs_id;

    IF v_sayi = 0 THEN
        RAISE EXCEPTION 'Bu kursa kayıtlı olmayan öğrenci yorum yapamaz.';
    END IF;

    RETURN NEW;
END;
$$;


CREATE OR REPLACE FUNCTION yorum_sonra_kurs_puani()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
DECLARE
    v_kurs_id INTEGER;
BEGIN
    IF TG_OP = 'INSERT' OR TG_OP = 'UPDATE' THEN
        v_kurs_id := NEW.kurs_id;
    ELSE
        v_kurs_id := OLD.kurs_id;
    END IF;

    PERFORM kurs_puan_guncelle(v_kurs_id);

    RETURN NULL;
END;
$$;


CREATE OR REPLACE FUNCTION odeme_sonra_kayit_durumu()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    PERFORM kayit_durum_guncelle(NEW.kayit_id);
    RETURN NULL;
END;
$$;


