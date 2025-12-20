CREATE OR REPLACE FUNCTION ogrenci_disjoint_kontrol()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
  IF EXISTS (
    SELECT 1
    FROM Egitmen
    WHERE kullanici_id = NEW.kullanici_id
  ) THEN
    RAISE EXCEPTION
      'Bu kullanıcı zaten eğitmen. Aynı kullanıcı öğrenci olamaz.';
  END IF;

  RETURN NEW;
END;
$$;

CREATE OR REPLACE FUNCTION egitmen_disjoint_kontrol()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
  IF EXISTS (
    SELECT 1
    FROM Ogrenci
    WHERE kullanici_id = NEW.kullanici_id
  ) THEN
    RAISE EXCEPTION
      'Bu kullanıcı zaten öğrenci. Aynı kullanıcı eğitmen olamaz.';
  END IF;

  RETURN NEW;
END;
$$;


CREATE TRIGGER trg_ogrenci_disjoint
BEFORE INSERT OR UPDATE ON Ogrenci
FOR EACH ROW
EXECUTE FUNCTION ogrenci_disjoint_kontrol();


CREATE TRIGGER trg_egitmen_disjoint
BEFORE INSERT OR UPDATE ON Egitmen
FOR EACH ROW
EXECUTE FUNCTION egitmen_disjoint_kontrol();
